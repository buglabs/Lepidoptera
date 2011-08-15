/**
 * @author jedahan
 */

(function() {
  window.initialize = function() {
    var buglabs, mapCanvas, mapGoogle, mapOptions, markers, socket, swarms, updateResource;
    swarms = [];
    swarms.push('142424f0919542c4fb60bbda4a254be645396ee9');
    swarms.push('b66dbbc74e2b1de4bde41bf353ceeb85cdd36bb6');
    buglabs = {
      lat: 40.72498216901785,
      lon: -73.99708271026611
    };
    console.log('connecting to swarm');
    try {
      socket = io.connect('http://107.20.250.52');
    } catch (e) {
      console.log('exception: ' + e);
    }
    socket.on('connect', function() {
      socket.emit('apikey', 'eae9f2188a375c4635138928b93c4b9f97d30803');
      return console.log('connected');
    });
    socket.on('message', function(message) {
      var data, dom_resource, dom_swarm, resource, swarm, _ref, _ref2;
      swarm = message.message.from.split('@')[0];
      dom_swarm = $("#" + swarm)[0] || $(".menu").append("<li><a href='#'>Swarm ID</a><ul id=" + swarm + " class='acitem'><li><a href='#'>No Resources</a></li></ul></li>");
      
      resource = (_ref = message.message) != null ? (_ref2 = _ref.from) != null ? _ref2.split('/')[1] : void 0 : void 0;
      
      if (resource != null) {
      	$("#" + swarm).replaceWith("<ul id=" + swarm + " class='acitem'></ul>");
        dom_resource = $("#" + resource)[0] || $("#" + swarm).append("<li id=" + resource + "><a href='#'>Resource</a></li>");
        data = JSON.parse(message.message.body.data);
        $("#" + resource).replaceWith("<li id=" + resource + " class='resource'><a href='#'>Resource MPG: " + data.mpg + "</a></li>");
        $('.menu').initMenu();
        return updateResource(dom_resource, data, resource);
      }
      $('.menu').initMenu();
    });
    socket.on('connected to backend', function() {
      var swarm, _i, _len;
      for (_i = 0, _len = swarms.length; _i < _len; _i++) {
        swarm = swarms[_i];
        socket.emit('message', {
          presence: {
            to: "" + swarm + "@swarms.bugswarm.net/web"
          }
        });
      }
      return console.log('connected to backend');
    });
    console.log("rendering map");
    mapOptions = {
      zoom: 12,
      center: new google.maps.LatLng(buglabs.lat, buglabs.lon),
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    
    mapCanvas = document.getElementById("map");
    mapGoogle = new google.maps.Map(mapCanvas, mapOptions);
    markers = [];
    return updateResource = function(dom_resource, data, resource) {
      var marker;
      console.log("updating " + dom_resource + " with " + (JSON.stringify(data)));
      marker = new google.maps.Marker({
        position: new google.maps.LatLng(data.latitude, data.longitude),
        icon: "http://robohash.org/" + resource + ".png?size=40x40&set=set3",
        map: mapGoogle,
        html: "<strong>" + data.mpg + "</strong>",
        title: data.name
      });
      google.maps.event.addListener(marker, 'click', function() {});
      return markers.push(marker);
    };
  };
}).call(this);


