<template>
  <div>
    <div class="title">
      <span class="red-text">Demand Draft</span>
      <span class="note">
                (
                <strong>Note</strong>: Please enter Demand Draft details below. In case there is more than one demand draft, then registration will need to be done seperately from each profile.)
              </span>
    </div>

    <SyddForm ref="paymentForm"/>
  </div>
</template>

<script>
  import SyddForm from './sydd_form'
  import PaymentSummary from './payment_summary'

  export default {
    components: {
      SyddForm,
      PaymentSummary
    },
    data: function () {
      return {}
    }
  }
</script>

<style>

</style>