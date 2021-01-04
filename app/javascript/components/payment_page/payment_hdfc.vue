<template>
  <div>
    <div class="title">
      <span class="red-text">Hdfc</span>
    </div>

    <CCavenueForm ref="paymentForm" method="hdfc"/>
  </div>
</template>
<script>
  import CCavenueForm from './ccavenue_form'
  import PaymentSummary from './payment_summary'

  export default {
    components: {
      CCavenueForm,
      PaymentSummary
    },
    data: function () {
      return {}
    }
  }
</script>

<style>

</style>
