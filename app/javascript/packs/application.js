// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import 'bootstrap'
import '../stylesheets/application'
import "@fortawesome/fontawesome-free/css/all"


window.onload = function(){
    var accept_item = $('#acceptance_item').html()
    if(accept_item == 'ng')
        $('#acceptance_item').css('background-color','#FF5C67')
    else
        $('#acceptance_item').css('background-color','#4CB5AE')

    var check_exist_item_in_container = document.querySelector('.item_result')
    var button_submit_container = document.querySelector('.item_submit')
    if(check_exist_item_in_container )
        button_submit_container.disabled = false;
    else
        button_submit_container.disabled = true;
    
    var select_value = $('#item_cog_height_type').html()
    alert(select_value)
}


Rails.start()
Turbolinks.start()
ActiveStorage.start()
