/**
 * Truncate Filter
 * @Param string
 * @Param int, default = 10
 * @Param string, default = "..."
 * @return string
 */
angular.module('CI').
  filter('truncate', function () {
      return function (text, length, end) {

        if (!angular.isString(text)) {
          return;
        }

        if (isNaN(length))
          length = 10;

        if (end === undefined)
          end = "...";

        if (text.length <= length || text.length - end.length <= length) {
          return text;
        } else {
          return String(text).substring(0, length-end.length) + end;
        }

      };
  });