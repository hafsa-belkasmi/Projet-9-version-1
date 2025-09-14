import { LightningElement, api, wire } from 'lwc';
import getTotalAmountByAccount
  from '@salesforce/apex/MyTeamOrdersController.getTotalAmountByAccount';

export default class Orders extends LightningElement {
  @api recordId;
  totalAmountOfCurrentAccount = 0;

  @wire(getTotalAmountByAccount, { accountId: '$recordId' })
  wireTotal({ data, error }) {
    if (data !== undefined) {
      this.totalAmountOfCurrentAccount = Number(data) || 0;
    } else if (error) {
      this.totalAmountOfCurrentAccount = 0;
    }
  }

  get hasTotal() {
    return Number(this.totalAmountOfCurrentAccount) > 0;
  }
}
