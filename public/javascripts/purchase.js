function queryCartForPurchase()
{
    httpRequest = new XMLHttpRequest();
    if(!httpRequest) {
        userError("Cart button XMLHttpRequest couldn't be created!");
        console.error("Whoops! An XMLHttpRequest couldn't be created...");
        return false;
    }
    httpRequest.onreadystatechange = cartQueried; 
    httpRequest.open("GET", "/user/cart.json")
    httpRequest.send();
}

function cartQueried()
{
    if(httpRequest.readyState == XMLHttpRequest.DONE)
    {
        if(httpRequest.status == 401) window.location = "/user/login";
        if(httpRequest.status == 200)
        {
            var resp = JSON.parse(httpRequest.responseText) 
            for (var key in resp)
            {
                if(resp.hasOwnProperty(key))
                {
                    console.log(key + "->" + resp[key].qty);
                }
            }
            httpRequest.onreadystatechange = purchaseCompleted;
            httpRequest.open("DELETE"," /user/cart");
            httpRequest.send();
        }
    }
}

function purchaseCompleted()
{
    if(httpRequest.readyState == XMLHttpRequest.DONE)
    {
            window.location = '/user/purchasethanks';
    }
}