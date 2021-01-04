<template>
  <div>
    <div class="title">
      <span class="red-text">Cash</span>
      <span class="note"></span>
    </div>

    <CashForm ref="paymentForm" method="cash" :payment-date="paymentDate" :amount="paymentAmount('cash')" :symbol="currencySymbol"/>
  </div>
</template>
<script>
  import CashForm from './cash_form'
  import PaymentSummary from './payment_summary'
  import {mapGetters} from 'vuex'

  export default {
    components: {
      CashForm,
      PaymentSummary
    },
    data: function () {
      return {}
    },
    computed: {
      ...mapGetters([
        'paymentDate',
        'paymentAmount',
        'currencySymbol'
      ])
    }
  }
</script>

<style>

</style>