final urlPrompt =
    "You are a helpful AI assistant tasked with extracting product information from the exact single ecommerce page provided. Input is the url of the product page.\n"
    "Forget any previous context or conversation history. Start fresh with the following instructions: \n"
    "I have provided you with the URL of a product page below. Please access this product landing page, analyze the content of the main product, and extract the following details of the main product only. "
    "1. Product Name: Upto 200 characters only.\n"
    "2. Product Price: Identify the correct selling price for the main product.Consider sales, discounts, and promotions:** If there's a sale price, provide that.Be precise:Include cents if they are present. Ignore price ranges:** If multiple prices are listed (e.g., for different sizes), choose the price that applies to the main product\n"
    "3. Product Description upto 200 characters only and trail the remaining with ellipses.\n"
    "4. Product Image URL: Find the image tag `<img>` that is used as the main product image. Extract the 'src' attribute value from that `<img>` tag. Don't get the dynamic image url or a url that is 404. Check if the url returns a valid image and not 404 error, otherwise look for other valid image. \n"
    "5. Product Category: Identify all categories and subcategories associated with the product. List them as a JSON array.\n"
    "6. Product Brand or manufacturer\n"
    "7. Product SKU\n"
    "8. Product Rating (if available): Give a single rating number only.\n"
    "9. Number of Product Reviews (if available)\n"
    "10. Product MRP: Identify the correct listing price for the main product.Consider original prices:** Look for original or list prices that might be crossed out or otherwise marked as non-current.\n"
    "11. Product Discount\n"
    "12. Currency used for Price: Provide the currency symbol as a string. For example: USD, INR, EUR, GBP etc.\n"
    "13. Provider or ecommerce merchant of this product like amazon,target,walmart etc. \n"
    "14. Product URL as given as the input\n"
    "15. Review Insights: Short summary or insights from User reviews\n\n"
    "16. Pros: At most 3 short and crisp pros based on User reviews. List them as a JSON array.\n\n"
    "17. Cons: Ar most 3 short and crisp cons based on User reviews. List them as a JSON array.\n\n"
    "Format your answer as a JSON object with the following keys: 'title', 'finalPrice', 'description', 'imageUrl', 'categories', 'brand', 'upin', 'rating', 'reviewsCount', 'initialPrice', 'discount', 'currency', 'provider', 'url', 'insights', 'pros', 'cons'. "
    "If any information is not available, exclude the key.\n"
    "Create a JSON object with list of all JSON  objects for each product.\n\n";

final imagePrompt =
    "You are a helpful AI assistant tasked with analyzing a product image and extracting relevant information. "
    "I have provided you with a product image. Please carefully analyze the image and describe the product as thoroughly as possible. "
    "If the image has multiple products, extract the details for each. Provide the following details:\n\n"
    "1. Product Name: Identify the product based on its appearance and provide a concise name upto 200 characters only.\n"
    "2. Product Price: If you can see any price on the image, provide the price.\n"
    "3. Product Description upto 200 characters only and trail the remaining with ellipses, based on visible features of the product. Include its color, material, shape, size, any branding or logos, any design elements, and any other noticeable characteristics.\n"
    "4. Product Image URL: This is the given input. \n"
    "5. Product Category: Categorize and subcategorize the product based on its general type. For example, is it a piece of clothing, a kitchen appliance, a toy, etc.? List them as a JSON array.\n"
    "6. Product Brand: \n"
    "7. Product SKU\n"
    "8. Product Rating (if available): Give a single rating number only.\n"
    "9. Number of Product Reviews (if available)\n"
    "10. Product MRP\n"
    "11. Product Discount\n"
    "12. Currency used for Price: Provide the currency symbol as a string. For example: USD, INR, EUR, GBP etc.\n"
    "13. Provider or ecommerce merchant of this product like amazon,target,walmart etc. \n"
    "14. Product URL if present\n\n"
    "Format your answer as a JSON object with the following keys: 'title', 'finalPrice', 'description', 'imageUrl', 'categories', 'brand', 'upin', 'rating', 'reviewsCount', 'initialPrice', 'discount', 'currency', 'provider', 'url'. "
    "If any information is not available, exclude the key.\n"
    "Create a JSON object with list of all JSON  objects for each product.\n\n";

final listDescriptionPrompt =
    "Please write a short and crisp description for a wishlist given its name and other details, and the details of items contained in it.\n"
    "If there are no items in the list, just write the description based on given information only.\n"
    "Don't include specific details of the items but just the theme.\n\n";

final listStoryPrompt =
    "Please write a short engaging narrative based on the wishlist given its name and other details, and the details of items contained in it.\n"
    "Example: A user wishes for a new DSLR camera, a tripod, and a photography book. Weave a story about a passionate photographer discovering their talent, using those items to capture stunning landscapes, and becoming an influencer.\n"
    "Goal is to make the wishlist more relatable and inspiring, going beyond mere product descriptions.\n"
    "If there are no items in the list, return null\n\n";

final categoryPrompt =
    "Given the title or descrition or both, of a product, Categorize and subcategorize the product based on its general type. For example, is it a piece of clothing, a kitchen appliance, a toy, etc.? List them as a JSON array.\n"
    "If there is not enough information, return an empty array.\n\n";

final personalizedListsPrompt =
    "Given a wishlists app that wants to create a feature that suggests personalized lists to users based on their existing lists and items.\n"
    "I have two datasets: Goldset: A set of lists and items that the user has created or followed.\n"
    "Testset: A set of lists and items that the user has not created or followed.\n"
    "I would like you to use the information in the goldset to analyze the user's preferences and then suggest list of maximum 5 personalized list suggestions from the testset only.\n"
    "For both sets, given information is List Name, List Key and Items Title.\n"
    "Just give the list keys for the output from the testSet only in a json array format. Response should strictly not include anything from the goldSet. If nothing, returns the empty array.\n\n";

final personalizedItemsPrompt =
    "Given a wishlists app that wants to create a feature that suggests personalized items to users based on their existing followed items.\n"
    "I have two datasets: Goldset: A set of items that the user has created or followed.\n"
    "Testset: A set of items that the user has not created or followed.\n"
    "I would like you to use the information in the goldset to analyze the user's preferences and then suggest list of maximum 10 personalized items suggestions from the testset only.\n"
    "For both sets, given information is Items Title and Items Key.\n"
    "Just give the item keys for the output from the testSet only in a json array format. Response should strictly not include anything from the goldSet. If nothing, returns the empty array.\n\n";

final generateListsPrompt =
    "Given a wishlist app that wants to create a feature that suggests personalized lists to users based on their existing items.\n"
    "I have a set of items that the user has added. Given the item name and item keys, \n"
    "Please analyze these items and suggest list suggestions based on common groupable theme and usage among items.\n"
    "Lists may not be only based on the categories of the items but can be based on the common usage, purpose or attributes of the items.\n"
    "For each list suggestion, provide a short and crisp list name and an array of at least 8 item keys that belongs to that list, prefer adding more and more. Don't suggest lists with less than 8 items.\n"
    "Give the output in the json array format with each element containing list name and array of item keys in that list.\n\n";
