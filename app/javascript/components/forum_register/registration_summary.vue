<template>
  <div id="registration_summary_screen" class="animate form">
    <!--Registration Summary Screen Starts Here-->
    <div class="registration_summary_wrapper">
      <div class="alert-warning p-3" v-if="isRenew">
        Forum memberships for following users will be renewed and extended 1 year.
      </div>

      <div class="alert-warning p-3" v-if="isTransfer">
        Forum memberships for following users will be transferred to this forum. No payments needed.
      </div>

      <div class="heading_title_small">Registration Summary</div>
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
                <th>Delete</th>
              </tr>
              </thead>
              <tbody>
              <tr v-for="(member, index) in members" :key="member._id">
                <td>{{index+1}}</td>
                <td>{{member.isNew ? member.newSadhakProfile.firstName : member.searchFirstName }}</td>
                <td>{{member.isNew ? 'SY'+member.sadhakProfileId : member.searchEmailOrMobileOrSyid }}</td>
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
          <div
            v-if="!isTransfer"
            class="total_amount">{{ total | currency(symbol) }}</div>
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
    props: {
      isTransfer: Boolean,
      isRenew: Boolean,
    },
    data: function () {
      return {}
    },
    components: {
      PaymentSummary
    },
    computed: {
      ...mapState(['members']),
      ...mapGetters({
        symbol: 'currencySymbol',
        total: 'priceSum'
      })
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
