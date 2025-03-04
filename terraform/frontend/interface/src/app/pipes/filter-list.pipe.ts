import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'filterList'
})
export class FilterListPipe implements PipeTransform {
  transform(items: Array<any>, search_for: string, search_in: string): Array<any> {
    if (search_for) return items.filter(item => item[search_in].indexOf(search_for) !== -1);
    else return items;
  }
}
