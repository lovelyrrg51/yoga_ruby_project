<template>
  <div v-if="paymentSummary" class="payment_summary_box bg-red">
    <div class="title">Payment Summary</div>
    <div class="description">
      <div class="row">
        <div class="col-sm-12 m-b-20">
          <table>
            <tr>
              <td width="65%">
                <div class="description_left">Registration Fees</div>
              </td>
              <td>
                <div class="description_right">{{fee | currency(symbol)}}</div>
              </td>
            </tr>
            <tr>
              <td>
                <div class="description_left">No. of Attendees</div>
              </td>
              <td>
                <div class="description_right">x{{attendeeNum}}</div>
              </td>
            </tr>
            <tr>
              <td>
                <div class="description_left">Discount Amount</div>
              </td>
              <td>
                <div class="description_right">{{discount | currency(symbol)}}</div>
              </td>
            </tr>
            <tr v-for="tax in paymentSummary.tax_breakup">
              <td>
                <div class="description_left">{{tax.tax_name}}</div>
              </td>
              <td>
                <div class="description_right">{{tax.amount | currency(symbol)}}</div>
              </td>
            </tr>

            <tr>
              <td>
                <div class="description_left">Total Amount</div>
              </td>
              <td>
                <div class="description_right">{{total | currency(symbol)}}</div>
              </td>
            </tr>

            <tr>
              <td>
                <div class="description_left">Tax Applicable</div>
              </td>
              <td>
                <div class="description_right">{{tax | currency(symbol)}}</div>
              </td>
            </tr>
          </table>
        </div>
      </div>
    </div>

    <hr class="payment_summary">

    <div class="description">
      <div class="row">
        <div class="col-sm-12 m-b-20">
          <table>
            <tr>
              <td width="65%">
                <div class="description_left">Net Amount</div>
              </td>
              <td>
                <div class="description_right">{{net | currency(symbol)}}</div>
              </td>
            </tr>

            <tr>
              <td>
                <div class="description_left">Additional Charge({{gatewayFee.percent}}%)</div>
              </td>
              <td>
                <div class="description_right">{{gatewayFee.amount | currency(symbol)}}</div>
              </td>
            </tr>
          </table>

        </div>
      </div>
    </div>

    <div class="total_amount">{{net + gatewayFee.amount | currency(symbol)}}<p class="center-text non-refundable">({{isIndiaEvent ? 'Non Refundable' : ''}})</p></div>
  </div>
</template>

<script>
  import {mapState, mapGetters} from 'vuex'


  export default {
    props: {
      'payMethod': {
        type: String,
        default: null
      }
    },
    data: function () {
      return {}
    },
    computed: {
      fee: function () {
        return this.paymentSummary["total_registration_fee"]
      },
      attendeeNum: function () {
        return this.memberCount
      },
      discount: function () {
        return this.paymentSummary["discount"]
      },
      total: function () {
        //return this.fee * this.attendeeNum - this.discount
        return this.paymentSummary["amount_before_taxes"]
      },
      tax: function () {
        return this.paymentSummary["service_tax"]
      },
      net: function () {
        return this.paymentSummary["total_payable_amount"]
      },
      gatewayFee: function () {
        if (this.payMethod && this.gateways && this.gateways[this.payMethod])
          return this.gateways[this.payMethod].fee
        return {
          fee: 0.0,
          amount: 0
        }
      },
      ...mapGetters(['memberCount', 'paymentSummary', 'gateways', 'isIndiaEvent']),
      ...mapGetters({
        symbol: 'currencySymbol'
      })
    }
  }
</script>

<style>

</style>
