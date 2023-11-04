import { Controller } from "@hotwired/stimulus"
import Map from 'ol/Map.js';
import OSM from 'ol/source/OSM.js';
import { useGeographic } from 'ol/proj';
import TileLayer from 'ol/layer/Tile.js';
import View from 'ol/View.js';
import {Heatmap as HeatmapLayer} from 'ol/layer.js';

useGeographic();


const vector = new HeatmapLayer({
    source: new VectorSource({
      url: 'data/kml/2012_Earthquakes_Mag5.kml',
      format: new KML({
        extractStyles: false,
      }),
    }),
    blur: parseInt(blur.value, 10),
    radius: parseInt(radius.value, 10),
    weight: function (feature) {
      // 2012_Earthquakes_Mag5.kml stores the magnitude of each earthquake in a
      // standards-violating <magnitude> tag in each Placemark.  We extract it from
      // the Placemark's name instead.
      const name = feature.get('name');
      const magnitude = parseFloat(name.substr(2));
      return magnitude - 5;
    },
  });

export default class extends Controller {
  connect() {
    console.log("Map connect...")
  
    const map = new Map({
        target: "map",
        layers: [
          new TileLayer({
            source: new OSM(),
          }),
        ],
        view: new View({
          center: [-123.11782250644546, 49.28062873449969],
          zoom: 13,
        }),
      });
  }

  rsz(event){
      console.log("Resizing chart...");
      this.element.Chart.resize();
     
  };
}


