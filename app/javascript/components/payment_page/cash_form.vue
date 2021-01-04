<template>
  <form id="stripe_form" action="#" :class="{'novalidate':!submitted, 'was-validated': submitted}">
    <div class="stripe_form">
      <div class="row">
        <div class="col-sm-6 ">
         <div class="input-group display-table">
            <span class="input-group-addon">
              <i class="material-icons">date_range</i>
            </span>
            <div class="form-line">
              <input type="text" name="payment_date" id="payment_date" class="form-control" :value="paymentDate" disabled/>
            </div>
          </div>
        </div>
        <div class="col-sm-6 ">
         <div class="input-group display-table">
            <span class="input-group-addon">
              <i class="material-icons">attach_money</i>
            </span>
            <div class="form-line">
              <input type="text" name="amount" id="amount" class="form-control" :value="amount | currency(symbol)" disabled/>
            </div>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-sm-12">
          <div class="md-form">
            <i class="material-icons prefix">mode_edit</i>
            <textarea id="comments" class="md-textarea form-control" rows="5"
                      required
                      v-model = "cash.comment"
                      v-validate="'required'"
            ></textarea>
            <label for="comments">Additional Comments</label>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-sm-12">
          <div class="md-form">
            <input type="checkbox" name="terms_condition_pay" id="terms_condition_pay"
                   class="form-control filled-in chk-col-red" required
                   v-validate="'required'"
                   v-model="cash.isTermsAccepted"
            >
            <label for="terms_condition_pay">I acknowledge that I have read all of the provisions above and
              fully understand the
              terms and conditions expressed and agree to be bound by such <a href="/terms_and_conditions/cash_payment" target="_blank">Terms and
                Conditions</a></label>
          </div>
        </div>
      </div>
    </div>
  </form>
</template>

<script>
  export default {
    props: ["method", "amount", "paymentDate", "symbol"],
    data: function () {
      return {
        cash: {
          comment: '',
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
            this.$store.commit('updateCashForm', this.cash)
          }
          resolve(valid)
        })
      }
    }
  }
</script>
