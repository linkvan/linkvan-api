import { Controller } from "@hotwired/stimulus"
import * as echarts from 'echarts';


// To connect use: data-controller="chart"
export default class extends Controller {
  connect() {
    console.log("Chart connect...")
    
    fetch('/admin/dashboard/timeseries')
      .then(response => response.json())
      .then(data => {
        console.log("data", data)

        this.element.Chart = echarts.init(this.element);
  
        let option;
        
        option = {
          dataset: {
            source: data
          },
          xAxis: {
            type: 'category',
            boundaryGap: false,
          },
          yAxis: {
            type: 'value'
          },
          series: [
            {
              type: 'line'
            }
          ]
        };
        
        option && this.element.Chart.setOption(option);
      
      })
      .catch(error => {
        console.error(error);
      }); 

    }

  rsz(event){
      console.log("Resizing chart...");
      this.element.Chart.resize();
     }
};

