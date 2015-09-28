
var ctx = $("#graph-canvas").get(0).getContext("2d");
var myChart;

$.ajax('projects.json', {
  dataType: 'json',

  success: function(projects) {
    var get_labels = function() {
      var bucket;

      var labels = []

      for (var i = 0; i < projects[0].buckets.length; i++) {
        labels.push('' + projects[0].buckets[i].week[1] + ' - ' + projects[0].buckets[i].week[0]);
      };

      return labels;
    };

    var get_types = function() {
      return $('.types li.active').map(function() {
        return $(this).attr('data-type');
      });
    };
    var get_dataset = function() {
      return $('.dataset li.active').attr('data-dataset');
    };
    var get_projects = function() {
      return $('.projects-list li.active').map(function() {
        return parseInt($(this).attr('data-project'), 10);
      });
    };

    var get_data = function() {
      var types = get_types();
      var dataset = get_dataset();
      var activated_projects = get_projects();

      var numbers = []
      for (var i = 0; i < get_labels().length; i++) {
        numbers.push(0);
      };

      var project;
      var info;
      for (var i = 0; i < activated_projects.length; i++) {
        project = projects[activated_projects[i]];
        for (var j = 0; j < project.buckets.length; j++) {
          info = project.buckets[j].info;
          if (info !== undefined) {
            for (var k = 0; k < types.length; k++) {
              if (info[types[k]] !== undefined) {
                if (info[types[k]][dataset] !== undefined) {
                  numbers[j] = numbers[j] + info[types[k]][dataset];
                }
              }
            }
          }
        }
      }

      return numbers;
    };

    var setup = function() {
      myChart = new Chart(ctx).Line({
        labels: get_labels(),
        datasets: [
          {
            fillColor: "rgba(77,188,233,0.2)",
            strokeColor: "rgba(77,188,233,1)",
            pointColor: "rgba(38,173,228,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(38,173,228,1)",
            data: get_data()
          },
        ]
      });
    };

    var redraw = function() {
      var data = get_data();

      for (var i = 0; i < data.length; i++) {
        myChart.datasets[0].points[i].value = data[i];
      }
      myChart.update();
    };

    $('.types li').click(function() {
      $(this).toggleClass('active');
      redraw();
    });

    $('.dataset li').click(function() {
      $('.dataset li').removeClass('active');
      $(this).addClass('active');
      redraw();
    });

    (function() {
      var project;

      for (var i = 0; i < projects.length; i++) {
        project = projects[i];

        var li = $('<li />').attr('data-project', i).text(project.name).addClass('active').appendTo($('.projects-list ul'));
        li.click(function() {
          $(this).toggleClass('active');
          redraw();
        });
      };
    })();

    $('.selection .select-all').click(function() {
      $('.projects-list li').addClass('active');
      redraw();
    });
    $('.selection .select-none').click(function() {
      $('.projects-list li').removeClass('active');
      redraw();
    });

    setup();
  }
})