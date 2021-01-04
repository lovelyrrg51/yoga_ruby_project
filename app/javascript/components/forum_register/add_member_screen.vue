<template>
  <div id="add_member_screen" class="animate form"><!--Add Member Screen Starts Here-->
    <div class="add_members_wrapper">
      <div class="heading_title_small">Add Members</div>
      <add-member-item v-for="(item, index) in members" :key="item._id" :id="index" ref="memberItems"/>
      <div class="row clearfix add_field_btn_wrapper">
        <div class="col-sm-12 align-right" v-if="!isFull">
          <div @click="addMember" class="m-r-20 cta_button_small pull-right"><i class="material-icons">add</i>&nbsp;Add More</div>
        </div>
        <div class="col-sm-12 align-center" v-else>
          <div class="alert alert-info alert-dismissable fade show" role="alert">
            <strong>you've reached to the limit ({{maxMemberSize}}) </strong>
            <button class="close" data-dismiss="alert" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div><!--Add Member Screen Ends Here-->
</template>
<script>
  import AddMemberItem from '../add_member_item'
  import {mapState, mapGetters, mapMutations} from 'vuex'

  export default {
    components: {
      AddMemberItem
    },
    created() {
      // this.addMember();
    },
    data: function () {
      return {}
    },
    computed: {
      ...mapState(['members', 'verifyMembersResult']),
      ...mapGetters(['memberCountToRegister', 'isFull', 'maxMemberSize'])
    },
    methods: {
      ...mapMutations([
        'addMember',
        'removeDummyMembers'
      ]),

      validate: function () {
        console.log('Add Member Screen Validate Module Called')
        return new Promise(async (resolve, reject) => {
          let valid = true, errorIndex;

          // remove dummy member box
          await this.removeDummyMembers()

          if (this.members.length < 1) {
            showNotification("alert-danger", 'Please add one member at least', "bottom", "center", "", "");
            this.addMember()
            resolve(false)
            return
          }

          for (let i = this.$refs.memberItems.length - 1; i >= 0; i--) {
            const ret = await this.$refs.memberItems[i].validate()
            if (!ret) {
              valid = false, errorIndex = i
            }
          }

          // scroll & set focus on first error
          // this.$refs.memberItems[errorIndex].$el.querySelector("[aria-invalid=true]").scrollIntoView(false);
          // this.$refs.memberItems[errorIndex].$el.querySelector("[aria-invalid=true]").focus();
          console.log(valid)
          if (valid) {
            //alert(this.memberCountToRegister)
            let loading
            try {

              // create new sadhak profiles
              if (this.memberCountToRegister > 0) {
                loading = this.$loading({fullscreen: true, text: 'Creating New Sadhak Profiles...'})
                await this.$store.dispatch('createBatchSadhakProfile')
                loading.close()

                showNotification("alert-success", 'Successfully Created Profiles!', "bottom", "center", "", "");
              }

              // check members if profile verified
              if(this.members.filter(member => !member.sadhakProfile.isVerified ).length !== 0){
                throw 'Please make sure that all members are verified.'
              }

              // verify members
              loading = this.$loading({fullscreen: true, text: 'Verifying Members...'})
              await this.$store.dispatch('verifyMembers')
              loading.close()

              if (this.verifyMembersResult) {
                const details = this.verifyMembersResult
                if (!details.transfer && !details.renew && !details.fresh) {
                  showNotification("alert-danger", 'Some profile(s) are eligible for transfer/renew and some are new registration(s). cannot process together. Aborting.', "bottom", "center", "", "");
                  valid = false
                } else if (details.transfer && details.renew) {
                  showNotification("alert-success", 'Transfer Renew', "bottom", "center", "", "");
                  // valid = true
                } else {
                  let message
                  if (details.fresh) message = "Proceed for Registrations."
                  if (details.transfer) message = "Proceed for Transfer."
                  if (details.renew) message = "Proceed for Renewal."
                  showNotification("alert-success", message, "bottom", "center", "", "");
                  // valid = true
                }
              } else {
                console.log('exception')
              }

            } catch (e) {
              if (loading) loading.close()
              showNotification("alert-danger", e, "bottom", "center", "", "");
              valid = false
            }
          }

          resolve(valid)
        })
      },
    }
  }
</script>
