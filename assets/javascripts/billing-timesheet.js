/*
Creating a Floating HTML Menu Using jQuery and CSS
http://nettuts.com/html-css-techniques/creating-a-floating-html-menu-using-jquery-and-css/

Used for the floating time counter
*/
var name = '#floating-counter';
var menuYloc = null;

jQuery(document).ready(function(){  
  menuYloc = parseInt(jQuery(name).css("top").substring(0, jQuery(name).css("top").indexOf("px")))

  // Listener for the scroll page event
  jQuery(window).scroll(function () {
    var offset = menuYloc + jQuery(document).scrollTop() + "px";
    jQuery(name).animate({top:offset},{duration:500,queue:false});
  });
});
