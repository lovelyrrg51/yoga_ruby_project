<template>
  <div>
    <div class="title">
      <span class="red-text">CCAvenue</span>
      <span class="note">
          (<strong>Note</strong>: Please don't attempt payments twice for same SYIDs. If fees is deducted from account and registration number not received then please inform Ashram helpline number or email to <a
          href="mailto:registration@shivyogindia.com">registration@shivyogindia.com</a> within 2 days of your transaction.)
        </span>
    </div>

    <CCavenueForm ref="paymentForm" method="ccavenue"/>
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
