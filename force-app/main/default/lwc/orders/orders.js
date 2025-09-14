import { LightningElement, api, wire } from 'lwc';
import getSumOrdersByAccount from '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount';

export default class Orders extends LightningElement {
  @api recordId;          // Id du compte courant
  sum = 0;

  @wire(getSumOrdersByAccount, { accountId: '$recordId' })
  wired({ data, error }) {
    if (data !== undefined) {
      this.sum = Number(data);
    } else if (error) {
      // En cas d'erreur, on retombe sur 0
      this.sum = 0;
      // console.error(JSON.stringify(error)); // décommente si tu veux tracer
    }
  }
}
