/*
 * Attaches a click event to a link which mimiks a form submission via Facebox
 */
(function($) {
  $.fn.jsLink = function(options) {
    var opts = $.extend({}, $.fn.jsLink.defaults, options);


    return this.each(function() {
      // apply plugin functionality to each element
      $(this).click(runFacebox);
    });

    function runFacebox() {
      var fieldsSelected = $(opts.selector);
      if (fieldsSelected.length > 0) {
        this.href = opts.basePath + '?';
        var link = this;
        fieldsSelected.each(function (ele) {
          link.href = link.href + opts.selectorFieldNames + this.value + '&';
        });

        $.facebox({ ajax: link.href });

        return false;
      } else {
        alert(opts.errorMessage);
        return false;
      }
    }
  };

  $.fn.jsLink.defaults = {
    basePath: '/',
    selector: '[rel=js-link]',
    errorMessage: 'No fields selected.',
    selectorFieldNames: 'value='
  };
})(jQuery);