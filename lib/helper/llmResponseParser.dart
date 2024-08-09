import 'package:dartz/dartz.dart';
import 'package:wish_pe/debug/addSnapshot.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/model/itemDetailModel.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/jsonResponseItemModel.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/state/searchState.dart';

Future<Tuple2<ItemModel, ItemDetailModel>> parseLLMResponse(
    Map<String, dynamic> jsonResponse,
    SearchState searchState,
    AuthState authState,
    List<dynamic>? imageUrls) async {
  try {
    final providersList = searchState.providerList;
    final element = JsonResponseItemModel.fromJson(jsonResponse);

    final itemModel = ItemModel(
        title: element.title,
        createdAt: DateTime.now().toUtc().toString(),
        categoryKeyList:
            await createCategoryKeyList(element, searchState.categorylist),
        imageUrl: imageUrls != null && imageUrls.isNotEmpty
            ? imageUrls[0]
            : element.image?.first,
        price: (element.currency ?? '') + ' ' + (element.finalPrice ?? ''),
        providerKey: (element.provider != null && element.provider!.isNotEmpty)
            ? (await getOrCreateProviderUser(element.provider!, providersList))
                .key
            : null,
        userId: authState.userId,
        likeCount: 0,
        likeList: []);
    final itemDetailModel = element.toItemDetailModel() as ItemDetailModel;
    if (imageUrls != null && imageUrls.isNotEmpty)
      itemDetailModel.images = imageUrls.cast<String>();
    return Tuple2(itemModel, itemDetailModel);
  } catch (error) {
    cprint(error, errorIn: 'parseLLMResponse');
    throw Exception('Failed to create item snapshot: $error');
  }
}
