import { Controller } from "@hotwired/stimulus";
import * as echarts from 'echarts';

export default class extends Controller {
  connect() {
    console.log("Chart connected!!!");
  
    const container = this.element;
    const chart = echarts.init(container);
  
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
    
    // Set the chart option
    option && chart.setOption(option);
  
   
  };
  rsz(event){
      console.log("Resizing chart...");
     
  };
}