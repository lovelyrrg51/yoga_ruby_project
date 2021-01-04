<template>
  <div>
    <form-wizard shape="tab" color="#F44336" error-color="#ff4949"
                 :start-index.sync="activeTabIndex"
                 ref="wizard"
                 @on-complete="onComplete"
                 @on-validate="onValidate"
    >
      <template v-slot:title>
      </template>
      <wizard-step slot-scope="props" slot="step" :tab="props.tab" :transition="props.transition" :index="props.index">
      </wizard-step>
      <tab-content title="1. Add Members" :before-change="() => validate('addMemberScreen')">
        <add-member-screen ref="addMemberScreen" @on-validate="onStepValidate"/>
      </tab-content>
      <tab-content title="2. Registration Summary" :before-change="() => validate('registrationSummary')">
        <member-transfer ref="registrationSummary" v-if="isRenew && isTransfer"/>
        <registration-summary
            :isTransfer="isTransfer"
            :isRenew="isRenew"
            ref="registrationSummary" v-else/>
      </tab-content>
      <tab-content title="3. Payment" :before-change="() => validate('paymentPage')" v-if="isNeededPayment">
        <payment-page :gateways="gateways" ref="paymentPage" v-if="gateways"/>
      </tab-content>

      <template v-slot:footer="props">
        <div id="prevNextCtrls" class="control_btns">
          <a href="javascript:void(0)" role="button" tabindex="0" class="cta_button_small bg-red waves-effect"
             @click="props.prevTab" @keyup.enter="props.prevTab"
             v-if="props.activeTabIndex == 1"
          > Back</a>
          <a href="javascript:void(0)" role="button" tabindex="0" class="cta_button_small bg-red waves-effect confirm-btn"
             @click="props.nextTab" @keyup.enter="props.nextTab"
             v-if="props.isLastStep && isIncludePaymentStep"
          > Confirm & Pay</a>
          <a href="javascript:void(0)" role="button" tabindex="0" class="cta_button_small bg-red waves-effect"
             @click="props.nextTab" @keyup.enter="props.nextTab"
             v-if="props.activeTabIndex==0"
          > Go To Step 2 (Summary)</a>
          <a href="javascript:void(0)" role="button" tabindex="0" class="cta_button_small bg-red waves-effect"
             @click="props.nextTab" @keyup.enter="props.nextTab"
             v-if="props.activeTabIndex==1"
          > {{ secondNextButtonTitle }}</a>
        </div>
      </template>
    </form-wizard>
  </div>
</template>
<script>
  import AddMemberScreen from './add_member_screen'
  import RegistrationSummary from './registration_summary'
  import MemberTransfer from './member_transfer'
  import PaymentPage from '../payment_page/payment_page'
  import {mapMutations} from 'vuex'
  import _ from 'lodash'

  export default {
    props: {
      forumId: {
        type: Number,
        default: null
      },
      seatingCategoryList: {
        type: Array,
        default: () => []
      },
      currency: {
        type: String,
        default: 'USD'
      }
    },
    components: {AddMemberScreen, RegistrationSummary, MemberTransfer, PaymentPage},
    data: function () {
      return {
        activeTabIndex: 0
      }
    },
    computed: {
      gateways() {
        const gateways = this.$store.getters.gateways
        if (gateways && !_.isEmpty(gateways)) {
          const gatewayNameAry = Object.keys(gateways)
          return gatewayNameAry
        }
        return null
      },
      secondNextButtonTitle() {
        return (this.isTransfer && !this.isRenew) ? 'Transfer' : 'Go To Step 3 (Payment)'
      },
      isTransfer() {
        const result = this.$store.state.verifyMembersResult
        return !!result && result.transfer
      },
      isRenew() {
        const result = this.$store.state.verifyMembersResult
        return !!result && result.renew
      },
      isNeededPayment() {
        const result = this.$store.state.verifyMembersResult
        return !!result && (result.fresh || result.renew)
      },
      isIncludePaymentStep() {
        return this.isNeededPayment
      }
    },
    created() {
      this.setForumId(this.forumId)
      this.setSeatingCategoryList(this.seatingCategoryList)
      this.setCurrency(this.currency)
    },
    methods: {
      ...mapMutations([
        'setForumId',
        'setSeatingCategoryList',
        'setCurrency',
      ]),
      onComplete: function () {
        // alert('confirmPay')
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
          //swal("Success !", "Form Submitted ! ", "success");
          const loading = this.$loading({
            fullScreen: true,
            text: "Payment Processing...\n Please don't close your browser while processing"
          })

          // api
          this.$store.dispatch('pay').then(({data: result}) => {
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
          return false;
        });
      },
      validate(ref) {
        return this.$refs[ref].validate();
      },
      onStepValidate(validated, model) {
        if (validated) {
          console.log('onStepValidate')
        }
      },
      onValidate: function (isValid, tabIndex) {
        if (tabIndex === 0 && isValid) {
          this.$store.commit('updateSeatingCategoryIds')
        }
      },
      submit(formData) {
        // form submit
        const form = document.createElement("form");
        form.setAttribute("charset", "UTF-8");
        form.setAttribute("method", "Post");
        form.setAttribute("action", `/event_orders/${this.$store.processClubMembersResult.event_order_id}/pay`);

        for (var pair of formData.entries()) {
          console.log(pair[0] + ', ' + pair[1]);

          const hiddenField = document.createElement("input");
          hiddenField.setAttribute("type", "hidden");
          hiddenField.setAttribute("name", pair[0]);
          hiddenField.setAttribute("value", pair[1]);

          form.appendChild(hiddenField);
        }

        document.body.appendChild(form);
        form.submit();
      }
    }
  }
</script>
<style lang="scss">
  #registration_summary_screen, #add_member_screen, #payment_options_screen {
    position: static;
  }

  #registration_summary_screen, #payment_options_screen {
    opacity: 100
  }

  .vue-form-wizard {
    .wizard-header {
      display: none;
    }

    .stepTitle.active {
      font-weight: bold;
    }

    .wizard-nav-pills {
      display: block !important;

      li {
        display: inline-block !important;
        padding: 15px 70px;
        border-bottom: 1px solid #E7EBEE;
        cursor: pointer;

        &.active {
          box-shadow: 0px -3px 0px #F44336 inset;
        }
      ;
      }
    }

    .wizard-icon-circle.tab_shape {
      display: none;
    }

    .wizard-progress-bar {
      display: none;
    }
  }

</style>
