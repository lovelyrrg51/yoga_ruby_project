<template>
  <div id="registration_summary_screen" class="animate form">
    <!--Registration Summary Screen Starts Here-->
    <div class="registration_summary_wrapper">
      <div class="heading_title_small">Registration Summary</div>

      <div class="row clearfix" v-if="isAshramResidentialShivir">
        <div class="col-sm-12">
          <div class="complete-alert bg-green text-align-center">
            <i class="material-icons vertical-align-middle">check_circle</i>&nbsp;This event is free to join and no
            payment is required. However your application needs to be approved by admin.
          </div>
        </div>
      </div>

      <div class="row clearfix" v-if="free">
        <div class="col-sm-12">
          <div class="complete-alert bg-green text-align-center">
            <i class="material-icons vertical-align-middle">check_circle</i>&nbsp;This event is free to join and no
            payment is required.
          </div>
        </div>
      </div>

      <div class="row clearfix" v-if="preApprovalRequired">
        <div class="col-sm-12">
          <div class="complete-alert bg-green text-align-center">
            <i class="material-icons vertical-align-middle">check_circle</i>&nbsp;The registration needs to be approved
            by the event organizer. You could proceed payment (if applicable) after your registration is approved.
          </div>
        </div>
      </div>

      <div class="row clearfix">
        <div class="col-sm-12" :class="{'novalidate': !submitted, 'was-validated': submitted}">
          <div class="attendees_summary">
            <!--<div class="attendee_info"></div>-->
            <table class="table table-hover">
              <thead>
              <tr>
                <th>#</th>
                <th>First Name</th>
                <th>Mobile/Email/SYID</th>
                <th>Category</th>
                <th v-if="!free">Amount</th>
                <th>Delete</th>
              </tr>
              </thead>
              <tbody>
              <tr v-for="(member, index) in members" :key="member._id">
                <td>{{index+1}}</td>
                <td>{{member.isNew ? member.newSadhakProfile.firstName : member.searchFirstName }}</td>
                <td>{{member.isNew ? 'SY'+member.sadhakProfileId : member.searchEmailOrMobileOrSyid }}</td>
                <td>
                  <div class="md-form margin-0-auto">
                    <select class="form-control" @change="chooseSeat(index, $event)" required
                            v-validate="'required'"
                    >
                      <option value="" disabled selected>---Category---</option>
                      <option v-for="(seat, seatIndex) in seatingCategoryList"
                              :value="seatIndex"
                              :key="seatIndex"
                              :selected="seatIndex===0 && free">
                        {{seat.category_name}}
                      </option>
                    </select>
                  </div>
                </td>
                <td v-if="!free">{{priceSeating(member.seatingCategoryId) | currency(currencySymbol)}}</td>
                <td v-if="members.length > 1">
                  <a
                      href="#"
                      rel="tooltip"
                      data-placement="top"
                      title="Delete"
                      @click="removeItem(index, $event)"
                      data-turbolinks="false"
                  >
                      <span class="remove_btn col-red">
                        <i class="material-icons">close</i>
                      </span>
                  </a>
                </td>
                <td v-else></td>
              </tr>
              </tbody>
            </table>
          </div>
          <div class="md-form">
            <input type="email" name="conf_email_id" id="conf_email_id" class="form-control"
                   :disabled="!!currentUserEmail"
                   required
                   v-model="receiveEmail"
                   v-validate="'required|email'"
                   data-vv-as="confirm email"
            >
            <label for="conf_email_id" :class="{active: !!currentUserEmail}">Email Address for receiving registration
              confirmation</label>
            <span v-show="errors.has('conf_email_id')"
                  class="invalid-feedback">{{ errors.first('conf_email_id') }}</span>
          </div>
          <div class="total_amount" v-if="!free">{{ total | currency(symbol) }}</div>
          <div class="md-form">
            <input type="checkbox" name="terms_condition" id="terms_condition"
                   class="form-control filled-in chk-col-red" required
                   v-validate="'required'"
            >
            <label for="terms_condition">I acknowledge that I have read all of the provisions above and
              fully understand the
              terms and conditions expressed and agree to be bound by such <a href="/terms_and_conditions/event_register" target="_blank">Terms and
                Conditions</a></label>
            <span v-show="errors.has('terms_condition')"
                  class="invalid-feedback">{{ errors.first('terms_condition') }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
  <!--Registration Summary Screen Ends Here-->
</template>
<script>
  import {mapState, mapGetters, mapMutations} from 'vuex'
  import PaymentSummary from '../payment_page/payment_summary'

  export default {
    props: {
      currentUserEmail: String,
      free: Boolean,
      preApprovalRequired: Boolean,
      isAshramResidentialShivir: Boolean,
    },
    data: function () {
      return {
        submitted: false,
      }
    },
    components: {
      PaymentSummary
    },
    created() {
      if (!!this.currentUserEmail)
        this.setGuestEmail(this.currentUserEmail)
    },
    computed: {
      ...mapState(['members', 'seatingCategoryList', 'guestEmail']),
      ...mapGetters(['priceSeating', 'currencySymbol']),
      ...mapGetters({
        symbol: 'currencySymbol',
        total: 'priceSum'
      }),
      receiveEmail: {
        get() {
          return this.guestEmail
        },
        set(value) {
          this.setGuestEmail(value)
        }
      }
    },
    methods: {
      ...mapMutations(['setGuestEmail']),
      removeItem: function (row, event) {
        event.preventDefault()
        this.$store.commit('removeMember', row)
      },
      chooseSeat: function (row, event) {
        const selected = event.target.selectedIndex
        if (selected > 0) {
          const categoryId = selected - 1   // select box start with index = 1, the first one is disabled option
          const seatingCategoryId = this.seatingCategoryList[categoryId].id
          this.$store.commit('updateSeatingCategoryId', {id: row, seatingCategoryId})
        }
      },
      validate: async function () {
        const valid = await this.$validator.validateAll()
        this.submitted = true

        if (!valid) {
          return valid
        }

        const loading = this.$loading({fullscreen: true, text: 'Creating Event Orders...'})
        try {
          if (this.members.length < 1)
            throw 'Please add one member at least'

          const result = await this.$store.dispatch('createEventOrder')
          loading.close()
          showNotification("alert-success", result.message, "bottom", "center", "", "");

          // Redirect if free or pre_approval_required
          if ((result.free || result.pre_approval) && result.redirect_path) {
            window.location.href = result.redirect_path
            // delay 700ms while redirecting
            await new Promise(resolve => setTimeout(() => resolve(), 700))
          }
          return true
        } catch (e) {
          loading.close()
          showNotification("alert-danger", e, "bottom", "center", "", "");
          return false
        }
      }
    }
  }
</script>
<style>
  .total_amount {
    text-align: right;
    font-size: 25px;
    font-weight: bold;
  }
</style>
