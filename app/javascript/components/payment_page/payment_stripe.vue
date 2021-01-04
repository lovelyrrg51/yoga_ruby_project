<template>
  <div>
    <div class="title">
      <span class="red-text">Stripe</span>
      <span class="note" v-if="forumId">
            (
            <strong>Note</strong>: Automatic renewal is supported for International Forums.)
          </span>
    </div>

    <div class="credit_card_icons">
      <img src="/images/credit_card_icons.png" class="img-fluid">
    </div>
    <PaymentForm ref="paymentForm" gateway="stripe" :publishableKey="publishableKey" v-if="publishableKey"/>
  </div>
</template>

<script>
  import PaymentForm from './stripe_form'
  import PaymentSummary from './payment_summary'
  import {mapState, mapGetters} from 'vuex';

  export default {
    components: {
      PaymentForm,
      PaymentSummary
    },
    data: function () {
      return {}
    },
    computed: {
      ...mapState(['forumId']),
      ...mapGetters(["publishableKey"])
    }
  }
</script>

<style>

</style>