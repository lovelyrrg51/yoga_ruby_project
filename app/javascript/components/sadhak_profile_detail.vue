<template>
  <div v-if="member" class="row clearfix member_info_div" id="member_info_div_1" style="display: block;">
    <div class="col-sm-12">
      <div class="row">
        <div class="col-sm-12">
          <div class="title">Looks like this member is already registred with us.</div>
        </div>
      </div>

      <div
          v-if="!member.isVerified"
          class="alert-warning p-3 animated fadeIn"
          role="alert"
      >
        This profile is not verified, it needs to be verified before being added to registration
        <br>
        <button @click="verifyEmail" type="button" class="btn cta_button_small bg-red waves-effect" v-if="verifyLink.email">Verify Email</button>
        <button @click="verifyMobile" type="button" class="btn cta_button_small bg-red waves-effect" v-if="verifyLink.mobile">Verify Mobile</button>
      </div>
      <div class="row">
        <div class="col-sm-6">
          <div class="row">
            <div class="col-sm-12">
              <div class="member_details">
                <span class="title">Full Name: </span>{{ member.fullName }}
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-sm-12">
              <div class="member_details">
                <span class="title">Gender: </span>{{ member.gender }}
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-sm-12">
              <div class="member_details">
                <span class="title">Email: </span>{{ member.obscureEmail }}
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-sm-12">
              <div class="member_details">
                <span class="title">Mobile: </span>{{ member.obscureMobile }}
              </div>
            </div>
          </div>
        </div>

        <div class="col-sm-6">
          <div class="row">
            <div class="col-sm-12">
              <div class="member_details">
                <span class="title">Address: </span>xxxxxx
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-sm-12">
              <div class="member_details">
                <span class="title">City: </span>{{ member.city }}
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-sm-12">
              <div class="member_details">
                <span class="title">State: </span>{{ member.state }}
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-sm-12">
              <div class="member_details">
                <span class="title">Country: </span>{{ member.country }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <SyModal :id="`verificationModal_${id}`" v-if="!member.isVerified" @closed="verifySadhakProfileComponentShow = false" >
      <h4 slot="header" class="modal-title">Profile Verification</h4>
      <VerifySadhakProfile slot="body" :verify-path="verifyPath" :resend-path="resendPath" :modal="true" @successed="profileVerified" v-if="verifySadhakProfileComponentShow"/>
    </SyModal>
  </div>
</template>

<script>
  import Axios from "axios";
  import {mapState, mapMutations} from "vuex"
  import SyModal from './sy_modal'
  import VerifySadhakProfile from "../VerifySadhakProfile"

  export default {
    props: {
      id: Number,
    },
    data: function() {
      return {
        modalShow: false,
        verifySadhakProfileComponentShow: false
      }
    },
    components: {
      SyModal,
      VerifySadhakProfile
    },
    computed: {
      ...mapState({
        member(state) {
          return state.members[this.id].sadhakProfile
        }
      }),
      verifyLink: function() {
        if(this.member)
          return this.member.verifyLink
        return null
      },
      slug: function() {
        if(this.member)
          return this.member.slug
        return null
      },
      verifyPath: function () {
        if (!this.slug)
          return null
        return `/sadhak_profiles/${this.slug}/verify_sadhak_profile/verify.json`
      },
      resendPath: function () {
        if (!this.slug)
          return null
        return `/sadhak_profiles/${this.slug}/verify_sadhak_profile/resend.json`
      }
    },
    methods: {
      ...mapMutations(['updateMemberVerifyState']),
      profileVerified: function(){
        $(`#verificationModal_${this.id}`).modal('hide');
        showNotification("alert-success", 'Successfully Verified', "bottom", "center", "", "");
        this.updateMemberVerifyState(this.id)
      },
      verifyEmail: function (e) {
        if (!!this.verifyLink && !!this.verifyLink.email) {
          Axios.patch(this.verifyLink.email + ".json").then((result) => {
            showNotification("alert-success", result.data.message, "bottom", "center", "", "");
            $(`#verificationModal_${this.id}`).modal('toggle')
            this.verifySadhakProfileComponentShow = true
          }).catch(result => {
            if(result.response && result.response.status === 503){
              showNotification("alert-danger", 'Too Many Requests!<BR>Please retry in 5 minutes', "bottom", "center", "", "");
            }else{
              showNotification("alert-danger", 'Unknown Server Error', "bottom", "center", "", "");
            }
          })
        }
      },
      verifyMobile: function (e) {
        if (!!this.verifyLink && !!this.verifyLink.mobile) {
          Axios.patch(this.verifyLink.mobile + ".json").then((result)=> {
            showNotification("alert-success", result.data.message, "bottom", "center", "", "");
            $(`#verificationModal_${this.id}`).modal('toggle')
            this.verifySadhakProfileComponentShow = true
          }).catch(result => {
            if(result.response && result.response.status === 503){
              showNotification("alert-danger", 'Too Many Requests!<BR>Please retry in 5 minutes', "bottom", "center", "", "");
            }else{
              showNotification("alert-danger", 'Unknown Server Error', "bottom", "center", "", "");
            }
          })
        }
      }
    }
  }
</script>

<style>

</style>
