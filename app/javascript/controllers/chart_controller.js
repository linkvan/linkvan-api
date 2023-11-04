import { Controller } from "@hotwired/stimulus"
import * as echarts from 'echarts';


// To connect use: data-controller="chart"
export default class extends Controller {
  connect() {
    console.log("Chart connect...")
   

    this.element.Chart = echarts.init(this.element);
  
    var option;
    
    option = {
      xAxis: {
        type: 'category',
        boundaryGap: false,
        data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      },
      yAxis: {
        type: 'value'
      },
      series: [
        {
          data: [820, 932, 901, 934, 1290, 1330, 1320],
          type: 'line',
          areaStyle: {}
        }
      ]
    };
    
    option && this.element.Chart.setOption(option);
  }

  rsz(event){
      console.log("Resizing chart...");
      this.element.Chart.resize();
     
  };
}


