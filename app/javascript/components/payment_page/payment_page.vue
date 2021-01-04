<template>
  <div id="payment_options_screen" class="animate form">
    <!--Payment Options Screen Starts Here-->
    <div v-if="gateways" class="payment_options_wrapper">
      <div class="heading_title_small">Payment</div>
      <ul id="tabs" class="nav nav-tabs" role="tablist">
        <li v-for="(name, index) in gateways" class="nav-item waves-effect waves-light" :key="index">
          <a :id="`tab-${name}`" :href="`#pane-${name}`" :class="['nav-link', {active: name === payMethod }]"
             data-toggle="tab" role="tab"
             @click="payMethod = name">
            <span :class="logos[name]"></span> {{name}}
          </a>
        </li>
      </ul>

      <div id="content" class="tab-content" role="tablist">
        <PaymentPane :name="payMethod" :title="payMethod" :active="true">
          <component :is="currentTabComponent" :ref="payMethod"></component>
        </PaymentPane>
      </div>
      <div class="row clearfix" v-if="!wizard">
        <div class="col-sm-12 text-center">
          <button class="btn cta_button_small bg-red waves-effect" @click="confirm">Confirm & Pay</button>
        </div>
      </div>
    </div>
  </div>
  <!--Payment Options Screen Ends Here-->
</template>
<script>
  import PaymentPane from './payment_pane'
  import PaymentStripe from './payment_stripe'
  import PaymentCcavenue from './payment_ccavenue'
  import PaymentHdfc from './payment_hdfc'
  import PaymentCash from './payment_cash'
  import PaymentSydd from './payment_sydd'
  import {mapState, mapGetters, mapMutations, mapActions} from 'vuex'

  const capitalize = (string) => string.charAt(0).toUpperCase() + string.slice(1)

  export default {
    props: {
      gateways: Array, // array of payment gateway name registered on the event, ex: ['stripe', 'sydd', 'cash', 'hdfc', 'ccavenue']
      wizard: {
        type: Boolean,
        default: true
      },
      orderData: {
        type: Object,
        default: null
      }
    },
    components: {
      PaymentPane,
      PaymentStripe,
      PaymentCcavenue,
      PaymentHdfc,
      PaymentCash,
      PaymentSydd
    },
    created() {
      if (!this.wizard && !!this.orderData) { // non-wizard, independent component
        this.updateProcessClubMembersResult(this.orderData)
        if (this.orderData.currency)
          this.setCurrency(this.orderData.currency)
      }
    },
    data: function () {
      return {
        payMethod: this.gateways[0],
        logos: {
          stripe: 'stripe_icon',
          cash: 'offline_payment_icon',
          ccavenue: 'net_banking_icon',
          hdfc: 'debit_card_icon',
          sydd: 'offline_payment_icon'
        }
      }
    },
    computed: {
      currentTabComponent: function () {
        return 'Payment' + capitalize(this.payMethod)
      }
    },
    methods: {
      validate: function () {
        this.$store.commit('updatePayMethod', this.payMethod)
        return this.$refs[this.payMethod].$refs["paymentForm"].validate()
      },
      confirm: function () {
        this.validate().then(valid => {
          if (!valid)
            return

          swal({
            title: "Are you sure you want to submit the form ?",
            text: "Make sure that you don't attempt payments twice for same SYIDs. If fees is deducted from account and registration number not received then please inform Ashram helpline number or email to support@absclp.com within 2 days of your transaction.",
            type: "warning",
            showCancelButton: true,
            cancelButtonText: "No, Let me check once again.",
            confirmButtonColor: "#DD6B55",
            showLoaderOnConfirm: false,
            confirmButtonText: "Yes, please submit the form !",
            closeOnConfirm: true
          }, () => {
            const loading = this.$loading({
              fullScreen: true,
              text: "Payment Processing...\n Please don't close your browser while processing"
            })

            // api
            this.pay().then(({data: result}) => {
              loading.close()
              if (result.success) {
                showNotification("alert-success", result.success, "bottom", "center", "", "");
                if (result.redirect_path) {
                  window.location.href = result.redirect_path
                }
              } else {
                if (result.error) {
                  showNotification("alert-danger", result.error, "bottom", "center", "", "");
                }
              }

            }).catch(err => {
              loading.close()
              showNotification("alert-danger", err, "bottom", "center", "", "");
            })
          })
        })
      },
      ...mapMutations(['updateProcessClubMembersResult', 'setCurrency']),
      ...mapActions(['pay'])

    }
  }
</script>
