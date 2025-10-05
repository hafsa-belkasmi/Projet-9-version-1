/**
 * ==============================================================
 * LWC Controller : Orders.js
 * ==============================================================
 * Objectif :
 *   - Récupérer et afficher le montant total des commandes associées
 *     au compte courant (recordId) via un appel à une méthode Apex.
 * 
 * Points clés :
 *   - Utilise @wire pour un appel réactif et cacheable côté client.
 *   - La méthode Apex MyTeamOrdersController.getSumOrdersByAccount
 *     renvoie un Decimal (somme totale) basé sur l'Id du compte.
 *   - Le composant est réutilisable sur une page de compte.
 * ==============================================================
 */

import { LightningElement, api, wire } from 'lwc';
import getSumOrdersByAccount from '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount';

export default class Orders extends LightningElement {

  /** 
   * @api recordId
   * Id du compte courant injecté automatiquement
   * lorsqu’on place le composant sur une page d’enregistrement.
   */
  @api recordId;

  /** 
   * Variable interne pour stocker la somme totale.
   * Par défaut initialisée à 0.
   */
  sum = 0;

  /**
   * Appel réactif à la méthode Apex via @wire.
   * Si le recordId change, la méthode est automatiquement relancée.
   * 
   * @param {Object} param0 - Contient les propriétés `data` et `error`
   *   renvoyées par le service wire.
   */
  @wire(getSumOrdersByAccount, { accountId: '$recordId' })
  wired({ data, error }) {
    // --- Cas succès ---
    if (data !== undefined) {
      // Conversion en nombre pour affichage correct
      this.sum = Number(data);
    } 
    // --- Cas erreur ---
    else if (error) {
      // En cas d’erreur, on remet la valeur à 0 par sécurité
      this.sum = 0;

      // Optionnel : décommenter la ligne suivante pour journaliser les erreurs
      // console.error(JSON.stringify(error));
    }
  }
}
