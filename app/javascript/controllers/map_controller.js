import { Controller } from "@hotwired/stimulus"
import Map from 'ol/Map.js';
import OSM from 'ol/source/OSM.js';
import { useGeographic } from 'ol/proj';
import TileLayer from 'ol/layer/Tile.js';
import View from 'ol/View.js';
import { Heatmap as HeatmapLayer, Vector as VectorLayer } from 'ol/layer.js';
import { Vector as VectorSource } from 'ol/source.js';
import { GeoJSON } from 'ol/format.js';

useGeographic();

export default class extends Controller {
  connect() {
    console.log("Map connect...");

    let points;

    fetch('/admin/dashboard/heatmap')
      .then(response => response.json())
      .then(data => {
        points = data;

        const heatLayer = new HeatmapLayer({
          title: "HeatMap",
          source: new VectorSource({
            features: new GeoJSON().readFeatures(points,{
              dataProjection: 'EPSG:4326',
    featureProjection: "EPSG:3857"  
            }
              ),
          })
        });
      
        const map = new Map({
          target: "map",
          layers: [
            new TileLayer({
              source: new OSM(),
            }),
            heatLayer, 
          ],
          view: new View({
            center: [-123.11782250644546, 49.28062873449969],
            zoom: 13,
          }),
        });
      })
      .catch(error => {
        console.error(error);
      }); 
  }

}