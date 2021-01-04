<template>
  <form id="stripe_form" action="#" :class="{'novalidate':!submitted, 'was-validated': submitted}">
    <div class="stripe_form">
      <div class="row">
        <div class="col-sm-12">
          <div class="input-group display-table">
            <span class="input-group-addon">
              <i class="material-icons">person</i>
            </span>

            <div class="form-line">
              <input type="text" name="card_holder" id="card_holder" class="form-control"
                     placeholder="Name (as it appears on your card)"
                     v-model="card.name"
                     v-validate="'required'"
                     data-vv-as="Name"
                     required>
            </div>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-sm-6">
          <div class="input-group display-table">
            <span class="input-group-addon">
              <i class="material-icons">phone</i>
            </span>
            <div class="form-line">
              <VueTelInput
                  name="mobile"
                  v-model="card.mobile"
                  v-validate="'required'"
                  :preferredCountries="['IN', 'US']"
              />
            </div>
          </div>
        </div>

        <div class="col-sm-6">
          <div class="input-group display-table">
            <span class="input-group-addon">
              <i class="material-icons">email</i>
            </span>
            <div class="form-line">
              <input type="email" class="form-control email" placeholder="Email ID" name="email" autocomplete="off"
                     v-model="card.email"
                     v-validate="'required|email'"
                     required>
            </div>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-sm-12">
          <div class="input-group display-table">
            <span class="input-group-addon">
              <i class="material-icons">credit_card</i>
            </span>
            <div class="form-line">
              <card class='stripe-card' :class='{ complete }' :stripe="publishableKey" :options="{hidePostalCode: true}" @change='complete = $event.complete'></card>
            </div>
          </div>
        </div>
      </div>

    </div>
  </form>
</template>

<script>
  import {Card, createToken} from "vue-stripe-elements-plus";
  import VueTelInput from 'vue-tel-input'

  export default {
    name: 'StripeForm',
    props: {
      gateway: {
        type: String,
        default: 'stripe'
      },
      publishableKey: String
    },
    components: {
      Card,
      VueTelInput
    },
    data: function() {
      return {
        card: {
          name: '',
          // cardNumber: '',
          // cvv: '',
          // expMon: '',
          // expYear: '',
          mobile: '',
          email: ''
        },
        token: '',
        submitted: false,
        complete: false
      }
    },
    methods: {
      validate: function () {
        return new Promise(async (resolve, reject) => {
          const valid = await this.$validator.validateAll()
          this.submitted = true

          if (!valid) {
            console.log('payment form validate failed')
            console.log(this.errors)
            showNotification("alert-warning", this.errors.items[0].msg, "bottom", "center", "", "");
            resolve(valid)
            return
          }

          if (!this.complete) {
            showNotification("alert-warning", 'Please input card number', "bottom", "center", "", "");
            resolve(this.complete)
            return
          }

          const loading = this.$loading({
            text: 'Token Creating'
          })

          createToken().then(token => {
            loading.close()
            if (token.error) {
              showNotification("alert-warning", token.error.message, "bottom", "center", "", "");
              resolve(false)
              return
            }

            this.token = token.token.id
            this.$store.commit('updateStripePaymentForm', {...this.card, token: this.token})
            resolve(true)
          });
        })
      }
    }
  }
</script>
<style>
  .stripe-card {
    /*width: 300px;*/
    border-bottom: 2px solid grey;
  }

  .stripe-card.complete {
    border-color: green;
  }
</style>