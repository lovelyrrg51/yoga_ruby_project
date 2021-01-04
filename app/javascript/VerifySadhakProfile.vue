<template>
  <div class="container vld-parent">
    <loading
      :active.sync="loading"
      :can-cancel="false"
      :color="'#BC0D0F'"
      :loader="'bars'"
      :is-full-page="false"
    ></loading>

    <div class="row clearfix">
      <div class="col-sm-12">
        <div class="card">
          <div class="body">
            <div class="header p-10-0 m-b-30"><h2>Verification Code</h2></div>
            <div class="form-horizontal login-form" v-if="success == false">
              <div class="alert-success p-3 text-align-center" v-if="successMessage">
                <i class="material-icons vertical-align-middle">check_circle</i>&nbsp;
                {{ successMessage }}
              </div>

              <div class="alert-danger p-3 text-align-center" v-show="errorMessage">
                <i class="material-icons vertical-align-middle">close</i>&nbsp;
                {{ errorMessage }}
              </div>

              <div class="input-group display-table m-30-auto width-310">
                  <span class="input-group-addon">
                    <i class="material-icons">phonelink_lock</i>
                  </span>
                <div class="form-line">
                  <input
                      v-model="token"
                      v-validate="'required|numeric'"
                      data-vv-as="verification code"
                      v-on:keyup.enter="verify"
                      type="text"
                      class="form-control"
                      name="verification_code"
                      placeholder="Verification Code"
                      autocomplete="new-password"
                      autofocus="true">
                </div>
              </div>
              <div class="text-center text-danger mt-0">
                {{ errors.first('verification_code') }}
              </div>

              <div class="row">
                <div class="col-xs-12 m-0-auto">
                  <button @click="verify"
                          class="btn cta_button_small bg-red waves-effect" type="button">Verify
                  </button>
                  &nbsp;&nbsp;&nbsp;
                  <button @click="resend"
                          :disabled="resendDisabled"
                          class="btn cta_button_small bg-red waves-effect" id="resend_btn" type="button">
                    Resend
                    <countdown
                        v-if="resendDisabled"
                        ref="countdown"
                        :time="countdown * 1000"
                        @end="countdown = 0"
                        @progress="writeCookie"
                    >
                      <template slot-scope="props">( {{ props.totalSeconds }} seconds )</template>
                    </countdown>
                  </button>
                  &nbsp;&nbsp;&nbsp;
                  <a class="btn cta_button_small bg-red waves-effect" :href="backPath" data-no-turbolink="true" v-if="!modal">Back</a>
                </div>
              </div>
            </div>

            <div class="form-horizontal login-form" v-if="success == true">
              <div class="alert bg-green text-align-center">
                <i class="material-icons vertical-align-middle">check_circle</i>&nbsp; Success ! You have successfully verified your Sadhak profile
              </div>

              <div class="row" v-if="!modal">
                <div class="col-xs-12 m-0-auto">
                  <a class="btn cta_button_small bg-red waves-effect" :href="backPath" data-no-turbolink="true">
                    Go to Sadhak Profile
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Loading from 'vue-loading-overlay'
import 'vue-loading-overlay/dist/vue-loading.css'

  export default {
    components: {
      Loading
    },
    props: {
      verifyPath: String,
      resendPath: String,
      backPath: String,
      modal: {
        type: Boolean,
        default: false
      }
    },
    data: () => {
      return {
        token: null,
        loading: false,
        successMessage: 'Please check your email/mobile for verification code!',
        errorMessage: null,
        countdown: 0, // 30 seconds
        success: false,
      }
    },
    created() {
      this.readCookie()
    },
    computed: {
      resendDisabled: function(){
        return this.countdown > 0
      }
    },
    methods: {
      readCookie() {
        const resendTime = Cookies.get('resend_timer')  // Todo fix to use props
        if(resendTime)
          this.countdown = parseInt(resendTime)
        else
          this.countdown = 0
      },
      writeCookie(data) {
        const secondsLeft = data.totalSeconds
        Cookies.set('resend_timer', secondsLeft, {expires: new Date(new Date().getTime() + secondsLeft  * 1000)})
      },
      verify(e) {
        e.preventDefault()
        this.$validator.validate().then(valid => {
          if (valid) {
            this.loading = true

            this.$axios.patch(this.verifyPath, {token: this.token})
              .then(response => {
                this.loading = false
                this.success = true
                this.errorMessage = null

                if (this.modal) {
                  this.$nextTick().then(() => {
                    this.$emit('successed')
                  })
                }
              })
              .catch(error => {
                this.errorMessage = error.response.data.message
                this.successMessage = null
                this.loading = false
              })
          }
        })
      },
      resend(e) {
        e.preventDefault()
        this.loading = true
        this.errorMessage = null
        this.successMessage = null
        this.$axios.patch(this.resendPath)
          .then(response => {
            this.successMessage = 'Verification code has been resent to your email/phone'
            this.loading = false
            this.readCookie()
          })
          .catch(error => {
            if(error.response && error.response.status === 503){
              this.errorMessage = 'Too Many Requests, Please retry in 5 minutes'
            }else {
              this.errorMessage = 'Cannot resend verification'
            }
            this.loading = false
          })
      }
    }
  }
</script>
