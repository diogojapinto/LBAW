function validateEmail(email) {
    var emailRegex = new RegExp("^.+\@.+\..+$");

    if(!emailRegex.test(email))
        showError('Email inválido!', 'danger');
    else
        return true;

    return false;
}

function validateUsername(username) {
    var usernameRegex = new RegExp("^\\S+$");

    if(!usernameRegex.test(username))
        showError('Nome de utilizador inválido', 'danger');
    else
        return true;

    return false;
}

function validateCompanyName(companyName) {
    var usernameRegex = new RegExp(".+");

    if(!usernameRegex.test(companyName))
        showError('Nome da empresa inválido', 'danger');
    else
        return true;

    return false;
}

function validateAddress(address) {
    var usernameRegex = new RegExp(".+");

    if(!usernameRegex.test(address))
        showError('Morada inválida', 'danger');
    else
        return true;

    return false;
}

function validateCity(city) {
    var usernameRegex = new RegExp(".+");

    if(!usernameRegex.test(city))
        showError('Cidade inválida', 'danger');
    else
        return true;

    return false;
}

function validatePostalCode(postalCode) {
    var usernameRegex = new RegExp(".+");

    if(!usernameRegex.test(postalCode))
        showError('Código postal inválido', 'danger');
    else
        return true;

    return false;
}

function validateCellphone(cellphone) {
    var usernameRegex = new RegExp("(\\+)?[-0-9]+");

    if(!usernameRegex.test(cellphone))
        showError('Número de telefone inválido', 'danger');
    else
        return true;

    return false;
}

function validatePassword(password1, password2) {
    var passwordRegex = new RegExp(".+");

    if( password1 !== password2 ) {

        showError('Passwords não coincidem', 'danger');

        return false;
    }

    if(!passwordRegex.test(password1) || !passwordRegex.test(password1))
        showError('Passwords inválidas!', 'danger');
    else
        return true;

    return false;
}

function validateRegisterBuyerForm() {
    var email = $("#inputEmail3").val();
    var username = $("#inputUsername3").val();
    var password1 = $("#inputPassword31").val();
    var password2 = $("#inputPassword32").val();

    return validateEmail(email) && validatePassword(password1, password2) && validateUsername(username);
}

function validateEditBuyerForm() {
    var email = $("#inputEmail3").val();
    var username = $("#inputUsername3").val();
    var password1 = $("#inputPassword31").val();
    var password2 = $("#inputPassword32").val();
    var toggle = true;

    if(email)
        toggle = toggle && validateEmail(email);

    if(password1 || password2)
        toggle = toggle && validatePassword(password1, password2);

    if(username)
        toggle = toggle && validateUsername(username);

    return toggle;
}

function validateRegisterSellerForm() {
    var email = $("#inputEmail3").val();
    var username = $("#inputUsername3").val();
    var password1 = $("#inputPassword31").val();
    var password2 = $("#inputPassword32").val();
    var companyName = $("#inputCompName").val();
    var address = $("#inputAddress3").val();
    var city = $("#inputCity3").val();
    var postalCode = $("#inputCity4").val();
    var cellphone = $("#inputCellphone3").val();

    return validateEmail(email) && validatePassword(password1, password2)
        && validateUsername(username) && validateCompanyName(companyName)
        && validateAddress(address) && validateCity(city)
        && validatePostalCode(postalCode) && validateCellphone(cellphone);
}

function validateEditSellerForm() {
    var email = $("#inputEmail3").val();
    var username = $("#inputUsername3").val();
    var password1 = $("#inputPassword31").val();
    var password2 = $("#inputPassword32").val();
    var companyName = $("#inputCompName").val();
    var address = $("#inputAddress3").val();
    var city = $("#inputCity3").val();
    var postalCode = $("#inputCity4").val();
    var cellphone = $("#inputCellphone3").val();
    var toggle = true;

    if(email)
        toggle = toggle && validateEmail(email);

    if(password1 || password2)
        toggle = toggle && validatePassword(password1, password2);

    if(username)
        toggle = toggle && validateUsername(username);

    if(companyName)
        toggle = toggle && validateCompanyName(companyName);

    if(address)
        toggle = toggle && validateAddress(address);

    if(city)
        toggle = toggle && validateCity(city);

    if(postalCode)
        toggle = toggle && validatePostalCode(postalCode);

    if(cellphone)
        toggle = toggle && validateCellphone(cellphone);

    return toggle;
}