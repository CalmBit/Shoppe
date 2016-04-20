function addToCart(itemID)
{
    httpRequest = new XMLHttpRequest();
    if(!httpRequest) {
        userError("Cart button XMLHttpRequest couldn't be created!");
        console.error("Whoops! An XMLHttpRequest couldn't be created...");
        return false;
    }
    httpRequest.onreadystatechange = cartItemAdded; 
    httpRequest.open("POST", "/cart/add")
    httpRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    httpRequest.send("itemID=" + encodeURIComponent(itemID));
}

function cartItemAdded()
{
    if(httpRequest.readyState == XMLHttpRequest.DONE)
    {
        if(httpRequest.status == 401) window.location = "/user/login";
        if(httpRequest.status == 404) userError('Product specified not found!');
        if(httpRequest.status == 200)
        {
            var resp = JSON.parse(httpRequest.responseText).response;
            switch(resp)
            {
                //fallback
                case 'login_requested':
                    window.location = "/user/login";
                    break;
                case 'product_invalid':
                    userError('Product specified not found!');
                    break;
                default:
                    alert(resp);
                    break;
            }
        }
    }
}