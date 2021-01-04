<template>
  <div>
    <form class="form-horizontal signup-form" id="signup_user" role="form">
      <div class="msg">SIGN UP</div>

      <div class="input-group display-table">
        <label for="Search_By" class="control-label">Sign up with</label>
        <div class="gender-radio-btn">
          <input type="radio" v-model="mode" id="email" value="email" class="radio-col-red with-gap" checked="checked">
          <label for="email"><i class="fa fa-envelope-o" aria-hidden="true"></i>&nbsp;Email</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" v-model="mode" id="phone" value="phone" class="radio-col-red with-gap">
          <label for="phone"><i class="fa fa-mobile-phone" aria-hidden="true"></i>&nbsp;Phone</label>
        </div>
      </div>

      <div class="input-group display-table" v-if="mode == 'email'">
        <span class="input-group-addon">
          <i class="material-icons">email</i>
        </span>
        <div class="form-line">
          <input
            v-model="email"
            v-validate="'required|email'"
            type="text"
            autofocus="autofocus" class="form-control" placeholder="Email" value="" name="email">
        </div>
        <span class="text-danger">{{ errors.first('email') }}</span>
      </div>

      <div class="input-group display-table" v-if="mode == 'phone'">
        <span class="input-group-addon">
          <i class="material-icons">phone</i>
        </span>
        <div class="form-line">
          <vue-tel-input
            v-model="mobile"
            v-validate="'required|mobile'"
            data-vv-as="mobile number"
            name="mobile_number"
            :preferredCountries="['IN', 'US']"
          ></vue-tel-input>
        </div>
        <span class="text-danger">{{ errors.first('mobile_number') }}</span>
      </div>

      <div class="input-group display-table">
        <span class="input-group-addon">
          <i class="material-icons">person</i>
        </span>
        <div class="form-line">
          <input
            v-model="first_name"
            v-validate="'required|alpha_spaces'"
            data-vv-as="first name"
            name="first_name"
            autocomplete="name"
            type="text" class="form-control" placeholder="First name">
        </div>
        <span class="text-danger">{{ errors.first('first_name') }}</span>
      </div>

      <div class="input-group display-table">
        <span class="input-group-addon">
          <i class="material-icons">lock</i>
        </span>
        <div class="form-line">
          <input
            v-model="password"
            v-validate="'required|min:6'"
            name="password"
            ref="confirmation"
            autocomplete="new-password" class="form-control" placeholder="Password" type="password">
        </div>
        <span class="text-danger">{{ errors.first('password') }}</span>
      </div>

      <div class="row">
        <div class="col-sm-5">
            Already have an account? <a href="/users/sign_in" class="to_register">Login Now!</a><br>
        </div>
        <div class="col-sm-7">
          <div
            @click="submit"
            :disabled="loading"
            value="Sign Up" class="cta_button_small signin_btn bg-red waves-effect">Sign Up</div>
        </div>
      </div>
    </form>
  </div>
</template>
<script>
import VueTelInput from 'vue-tel-input'
import 'vue-tel-input/dist/vue-tel-input.css'
import { parsePhoneNumberFromString } from 'libphonenumber-js'

export default {
  components: {
    VueTelInput
  },
  props: {
  },
  data: () => {
    return {
      mode: 'email', // email | phone
      email: null,
      mobile: null,
      first_name: null,
      password: null,
      loading: false,
      errorMessage: null,
      success: false,
    }
  },
  created () {
    this.$validator.extend('mobile', {
      getMessage: field => 'invalid mobile number.',
      validate: value => {
        const phone = parsePhoneNumberFromString(value.toString())
        return phone ? phone.isValid() : false
      }
    })
  },
  methods: {
    submit (e) {
      e.preventDefault()

      this.$validator.validate().then(valid => {
        if (!valid) { return }

        let data = {
          first_name: this.first_name,
          password: this.password,
        }

        if (this.mode === 'email') {
          data['email'] = this.email
        } else {
          data['mobile'] = this.mobile
        }

        this.loading = true

        this.$axios.post('/users', data)
          .then(response => {
            window.location.href = response.data.redirect_path
          })
          .catch(error => {
            this.loading = false

            const errors = error.response.data.errors
            if (errors.email)
              this.$validator.errors.add({
                field: 'email',
                msg: errors.email[0]
              })
            if (errors.mobile)
              this.$validator.errors.add({
                field: 'mobile',
                msg: errors.mobile[0]
              })
            if (errors.first_name)
              this.$validator.errors.add({
                field: 'first_name',
                msg: errors.first_name[0]
              })
          })

      })
    }
  },
}
</script>
<style scoped lang="scss">
.vue-tel-input {
  border: none;

  &:focus-within {
    box-shadow: none;
  }

  &::v-deep ul {
    z-index: 9999;
  }

  &::v-deep .dropdown:focus {
    outline: none;
  }
}
</style>
