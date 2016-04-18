// Tell a user, nicely, that something has broken on the site

var httpRequest;

function userError(error)
{
    alert("Oops! Tell an admin that `" + error + "`");
}

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
        if(httpRequest.status == 200)
        {
            var resp = JSON.parse(httpRequest.responseText).response;
            if(resp == "login_requested")
            {
                window.location = "/user/login"
            }
            else
            {
                alert(resp);
            }
        }
    }
}