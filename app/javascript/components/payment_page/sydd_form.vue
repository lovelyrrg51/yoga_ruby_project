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
                     v-model="demandDraft.fullName"
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
                     v-model="demandDraft.mobile"
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
              <input type="email" class="form-control email" placeholder="Email ID" name="email" autocomplete="off"
                     v-model="demandDraft.email"
                     v-validate="'required|email'"
                     required>
            </div>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-sm-6">
          <div class="input-group display-table">
            <span class="input-group-addon">
              <i class="material-icons">confirmation_number</i>
            </span>
            <div class="form-line">
              <input type="text" class="form-control" placeholder="Demand Draft Number" name="demand_draft_number"
                     v-model="demandDraft.ddNumber"
                     v-validate="'required'"
                     required>
            </div>
          </div>
        </div>
        <div class="col-sm-6">
          <div class="input-group display-table date" id="demand_draft_date_container">
            <span class="input-group-addon"><i class="material-icons">date_range</i></span>
            <div class="form-line sy-form-line">
              <input type="text" class="form-control sy-date" placeholder="Demand Draft Date" name="demand_draft_date"
                     v-model="demandDraft.ddDate"
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
              <i class="material-icons">home</i>
            </span>

            <div class="form-line">
              <input type="text" name="bank_name" id="bank_name" class="form-control"
                     placeholder="Bank Name"
                     v-model="demandDraft.bankName"
                     v-validate="'required'"
                     required>
            </div>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-sm-12">
          <div class="md-form">
            <input type="checkbox" name="terms_condition" id="terms_condition"
                   class="form-control filled-in chk-col-red" required
                   v-validate="'required'"
                   v-model="demandDraft.isTermsAccepted"
            >
            <label for="terms_condition">I agree to the <a href="/terms_and_conditions/demand_draft_payment" target="_blank">Terms and
              Conditions</a></label>
            <span v-show="errors.has('terms_condition')"
                  class="invalid-feedback">{{ errors.first('terms_condition') }}</span>
          </div>
        </div>
      </div>
    </div>
  </form>
</template>

<script>
  export default {
    props: ["method"],
    data: function () {
      return {
        demandDraft: {
          fullName: '',
          mobile: '',
          email: '',
          ddNumber: '',
          ddDate: null,
          bankName: '',
          isTermsAccepted: false
        },
        submitted: false
      }
    },
    mounted() {
      //Bootstrap datepicker plugin
      const datepickerId = '#demand_draft_date_container'
      $(datepickerId).datepicker({
        autoclose: true,
        container: datepickerId,
        format: 'yyyy-mm-dd'
      }).on(
        'changeDate', () => {
          this.demandDraft.ddDate = $(datepickerId + ' input').val();
        }
      );
    },
    methods: {
      validate: function () {
        return new Promise(async (resolve, reject) => {
          const valid = await this.$validator.validateAll()
          this.submitted = true
          console.log(valid)
          if (valid) {
            // update store
            this.$store.commit('updateDemandDraftForm', this.demandDraft)
          }
          resolve(valid)
        })
      }
    }
  }
</script>
