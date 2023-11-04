import { Controller } from "@hotwired/stimulus"
import Map from 'ol/Map.js';
import OSM from 'ol/source/OSM.js';
import TileLayer from 'ol/layer/Tile.js';
import View from 'ol/View.js';


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
          center: [0, 0],
          zoom: 2,
        }),
      });
  }

  rsz(event){
      console.log("Resizing chart...");
      this.element.Chart.resize();
     
  };
}


