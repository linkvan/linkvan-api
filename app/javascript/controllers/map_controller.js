import { Controller } from "@hotwired/stimulus"
import Map from 'ol/Map.js';
import OSM from 'ol/source/OSM.js';
import { useGeographic } from 'ol/proj';
import TileLayer from 'ol/layer/Tile.js';
import View from 'ol/View.js';
import { Heatmap as HeatmapLayer, Vector as VectorLayer } from 'ol/layer.js';
import { Vector as VectorSource } from 'ol/source.js';
import { GeoJSON } from 'ol/format.js';
import Feature from 'ol/Feature.js';
import Point from 'ol/geom/Point.js';

useGeographic();

export default class extends Controller {
  connect() {
    console.log("Map connect...");

    let points;

    fetch('/admin/dashboard/heatmap')
      .then(response => response.json())
      .then(data => {
        // Handle the JSON data
        points = data;

        // Create the vector source with the GeoJSON data
        const vectorSource = new VectorSource({
          features: new GeoJSON().readFeatures(points),
        });

        // Create the vector layer with the vector source
        const vectorLayer = new VectorLayer({
          source: vectorSource,
        });

        // Create the map with the vector layer
        const map = new Map({
          target: "map",
          layers: [
            new TileLayer({
              source: new OSM(),
            }),
            vectorLayer, // Add the vector layer to the layers array
          ],
          view: new View({
            center: [-123.11782250644546, 49.28062873449969],
            zoom: 13,
          }),
        });
      })
      .catch(error => {
        // Handle any errors from the HTTP request
        console.error(error);
      });
  }

  rsz(event) {
    console.log("Resizing chart...");
   
  };
}