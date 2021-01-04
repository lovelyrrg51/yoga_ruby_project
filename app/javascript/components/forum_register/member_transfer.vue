<template>
  <div id="registration_summary_screen" class="animate form">
    <!--Registration Summary Screen Starts Here-->
    <div class="registration_summary_wrapper">
      <div class="alert-warning p-3">
        Forum memberships for following users will be renewed and transferred to this forum.
      </div>

      <div class="heading_title_small">Member(s) Transfer</div>
      <div class="row clearfix">
        <div class="col-sm-12">
          <div class="attendees_summary">
            <!--<div class="attendee_info"></div>-->
            <table class="table table-hover">
              <thead>
              <tr>
                <th>#</th>
                <th>First Name</th>
                <th>Mobile/Email/SYID</th>
                <th>Registered Forum</th>
                <th>New Forum</th>
                <th>Message</th>
                <th>Membership Expiration Date</th>
                <th>Delete</th>
              </tr>
              </thead>
              <tbody>
              <tr v-for="(member, index) in members" :key="member._id">
                <td scope="row">{{index+1}}</td>
                <td>{{member.isNew ? member.newSadhakProfile.firstName : member.searchFirstName }}</td>
                <td>{{member.isNew ? 'SY'+member.sadhakProfileId : member.searchEmailOrMobileOrSyid }}</td>
                <td>{{member.verifyResult['sy_club_name']}}</td>
                <td>{{member.verifyResult['new_sy_club_name']}}</td>
                <td>{{member.verifyResult['message']}}</td>
                <td>{{member.verifyResult['expiration_date']}}</td>
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
          <div class="total_amount">{{ total | currency(symbol) }}</div>
        </div>
      </div>
      <div class="row">
        <div class="col-sm-12">
          <div class="md-form">
            <input type="checkbox" name="check" class="form-control filled-in chk-col-red" id="check_renew"
                   v-model="renew"
            >
            <label for="check_renew">Renew (Either all the Members will proceed For Renewal or None.)</label>
          </div>
        </div>
      </div>
      <div class="row clearfix">
        <div class="col-sm-12">
          <ul class="list-unstyled whitesmoke-bg listofterm">
            <li>New Registrations are not allowed to proceed with existing transfer/renewal requests.</li>
            <li>Renewal profiles on same forum are not allowed to proceed with transfer requests without renewal from
              other forum at same time.
            </li>
            <li>Renewal of profiles can be only done within a period of 30 days before the membership expires.</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
  <!--Registration Summary Screen Ends Here-->
</template>
<script>
  import {mapState, mapGetters} from 'vuex'
  import PaymentSummary from '../payment_page/payment_summary'

  export default {
    data: function () {
      return {
      }
    },
    components: {
      PaymentSummary
    },
    computed: {
      ...mapState(['members']),
      ...mapGetters({
        symbol: 'currencySymbol',
        total: 'priceSum'
      }),
      renew: {
        set(val) {
          this.$store.commit('updateRenew', val)
        },
        get(){
         return this.$store.state.renew
        }
      }
    },
    methods: {
      removeItem: function (row, event) {
        event.preventDefault()
        this.$store.commit('removeMember', row)
      },
      validate: async function () {
        const loading = this.$loading({fullscreen: true, text: 'Creating Event Orders...'})
        try {
          if(this.members.length < 1)
            throw 'Please add one member at least'

          const result = await this.$store.dispatch('process_club_members')
          loading.close()
          if(result.message)
            showNotification("alert-success", result.message, "bottom", "center", "", "");

          if(result.transfer && result.redirect_path){
            window.location.href = result.redirect_path
            // delay 700ms while redirecting
            await new Promise(resolve => setTimeout(()=>resolve(), 700))
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
