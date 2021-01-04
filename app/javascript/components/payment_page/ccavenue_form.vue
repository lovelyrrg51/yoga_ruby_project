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
                     placeholder="Name"
                     v-model="bill.name"
                     v-validate="'required'"
                     required>
            </div>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-sm-12">
          <div class="input-group display-table">
            <span class="input-group-addon">
              <i class="material-icons">location_on</i>
            </span>

            <div class="form-line">
              <input type="text" name="address" id="address" class="form-control" placeholder="Billing Address"
                     v-model="bill.address"
                     v-validate="'required'"
                     required>
            </div>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-sm-6">
          <div class="input-group display-table">
            <span class="input-group-addon">
              <i class="material-icons">location_on</i>
            </span>
            <div class="form-line">
              <input type="text" class="form-control" placeholder="Country" name="country"
                     v-model="bill.country"
                     v-validate="'required'"
                     required>
            </div>
          </div>
        </div>

        <div class="col-sm-6">
          <div class="input-group display-table">
            <span class="input-group-addon">
              <i class="material-icons">location_on</i>
            </span>
            <div class="form-line">
              <input type="text" class="form-control" placeholder="State" name="state"
                     v-model="bill.state"
                     v-validate="'required'"
                     required>
            </div>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-sm-6">
          <div class="input-group display-table">
            <span class="input-group-addon">
              <i class="material-icons">location_on</i>
            </span>
            <div class="form-line">
              <input type="text" class="form-control" placeholder="City" name="city"
                     v-model="bill.city"
                     v-validate="'required'"
                     required>
            </div>
          </div>
        </div>

        <div class="col-sm-6">
          <div class="input-group display-table">
            <span class="input-group-addon">
              <i class="material-icons">email</i>
            </span>
            <div class="form-line">
              <input type="text" class="form-control" placeholder="Postal Code" name="post_code"
                     v-model="bill.postalCode"
                     v-validate="'required'"
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
              <input type="text" class="form-control mobile-phone-number" placeholder="Mobile Number" name="mobile"
                     v-model="bill.mobile"
                     v-validate="'required'"
                     required>
            </div>
          </div>
        </div>

        <div class="col-sm-6">
          <div class="input-group display-table">
            <span class="input-group-addon">
              <i class="material-icons">email</i>
            </span>
            <div class="form-line">
              <input type="email" class="form-control email" placeholder="Email ID" name="email"  autocomplete="off"
                     v-model="bill.email"
                     v-validate="'required|email'"
                     required>
            </div>
          </div>
        </div>
      </div>
      <div class="row" v-if="method === 'hdfc'">
        <div class="col-sm-12">
          <div class="md-form">
            <input type="checkbox" name="terms_condition_hdfc" id="terms_condition_hdfc"
                   class="form-control filled-in chk-col-red" required
                   v-validate="'required'"
                   v-model="bill.isTermsAccepted"
                   data-vv-as="terms and condition"

            >
            <label for="terms_condition_hdfc">I acknowledge that I have read all of the provisions above and
              fully understand the
              terms and conditions expressed and agree to be bound by such <a href="#">Terms and
                Conditions</a></label>
            <span v-show="errors.has('terms_condition_hdfc')"
                  class="invalid-feedback">{{ errors.first('terms_condition_hdfc') }}</span>
          </div>
        </div>
      </div>
    </div>
  </form>
</template>

<script>
  export default {
    props:["method"],
    data: function () {
      return {
        bill: {
          name: '',
          address: '',
          country: '',
          state: '',
          city: '',
          postalCode: '',
          mobile: '',
          email: '',
          isTermsAccepted: false
        },
        submitted: false
      }
    },
    methods: {
      validate: function () {
        return new Promise(async (resolve, reject) => {
          const valid = await this.$validator.validateAll()
          this.submitted = true
          console.log(valid)
          if (valid) {
            // update store
            this.$store.commit('updateBillingForm', this.bill)
          }
          resolve(valid)
        })
      }
    }
  }
</script>
