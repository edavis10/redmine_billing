/*
Creating a Floating HTML Menu Using jQuery and CSS
http://nettuts.com/html-css-techniques/creating-a-floating-html-menu-using-jquery-and-css/

Used for the floating time counter
*/
var name = '#floating-counter';
var menuYloc = null;


// Allows an event to be delayed
//
// http://ihatecode.blogspot.com/2008/04/jquery-time-delay-event-binding-plugin.html
(function($){
    $.fn.delay = function(options) {

        var timer;
        function count(scope){
            if (timer != null) {
                clearTimeout(timer);
            }
            var newFn = function() {
                options.fn.apply(scope);
            };
            timer = setTimeout(newFn, options.delay);
        }
       
        return this.each(function() {
            var obj = $(this);
            obj.bind(options.event, function () {
                 count(this);  
            });
        });
    };
})(jQuery);

jQuery(document).ready(function(){

  // Floating time counter
  menuYloc = parseInt(jQuery(name).css("top").substring(0, jQuery(name).css("top").indexOf("px")))

  // Listener for the scroll page event
  jQuery(window).scroll(function () {
    var offset = menuYloc + jQuery(document).scrollTop() + "px";
    jQuery(name).animate({top:offset},{duration:500,queue:false});
  });

    // Needs a very small delay to give the Context Menu a chance to toggle
    // the checkbox
    jQuery('table.list').delay({
        delay: 1,
        event: 'click',
        fn: function() {
            updateCounter();
            updateCounterVisability();
        }
    });


    function updateCounter() {
        jQuery.getJSON(time_counter_url,
                    jQuery('form#time_entries input:checked').serialize(),
                    function (data, textStatus) {

                        // Update floating-counter
                        // TODO: Hard coded strings
                        jQuery('#total-time').html(data.total_time + ' | ' + data.total_amount);
                        jQuery('#time-entry-count').html(data.total_entries + ' Time Entries');

                        member_list = '';
                        // Build up the list
                        data.members.each(function(member, index) {
                            member_list += "<li>" + member.name + ": " + member.number_of_entries + " | " + member.formatted_time + " | " + member.formatted_amount +"</li>";
                        });

                        jQuery('#floating-counter ul').html(member_list);
                    });
    }

    function updateCounterVisability() {
        selected = jQuery('form#time_entries input:checked').length
        if (selected > 0) {
            jQuery('#floating-counter').show();
        } else {
            jQuery('#floating-counter').hide();
        }
    }

});
