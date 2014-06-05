function validateEmail(email) {
    var emailRegex = new RegExp(".+\@.+\..+");

    if(!emailRegex.test(email))
        showError('Email inválido!', 'danger');
    else
        return true;

    return false;
}

function validateUsername(username) {
    var usernameRegex = new RegExp(".+");

    if(!usernameRegex.test(username))
        showError('Nome de utilizador inválido', 'danger');
    else
        return true;

    return false;
}

function validatePassword(password1, password2) {
    var passwordRegex = new RegExp(".+");

    console.log(password1)
    console.log(password2)

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

    console.log(password1)
    console.log(password2)

    return validateEmail(email) && validatePassword(password1, password2) && validateUsername(username);
}