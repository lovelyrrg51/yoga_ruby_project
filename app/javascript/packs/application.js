import TurbolinksAdapter from 'vue-turbolinks'
import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import Axios from 'axios'

/********************** Element UI Framework Import ***********************************/
import {
  Loading,
  MessageBox,
  Notification,
  Message,
  Select,
  Option,
  RadioGroup,
  Radio,
  DatePicker,
  Form,
  FormItem
} from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
/********************** Element UI Framework Import ***********************************/

import '../assets/custom.css'
import 'vue-tel-input/dist/vue-tel-input.css'

import Accounting from 'accounting'
import ForumRegister from '../components/forum_register/forum_register'
import EventRegister from '../components/event_register/event_register'
import PaymentPage from '../components/payment_page/payment_page'
import FormWizard from "vue-form-wizard"
import "vue-form-wizard/dist/vue-form-wizard.min.css"
import VeeValidate from 'vee-validate'
import {resolve, reject} from 'q'
import VueCountdown from '@chenfengyuan/vue-countdown'

var uniqid = require('uniqid');

Vue.use(Vuex)
Vue.use(TurbolinksAdapter)

// axios global config
Vue.prototype.$axios = Axios

// Element UI Config
Vue.use(Select)
Vue.use(Option)
Vue.use(RadioGroup)
Vue.use(Radio)
Vue.use(DatePicker)
Vue.use(Form)
Vue.use(FormItem)

Vue.use(Loading.directive);

Vue.prototype.$loading = Loading.service;
// Vue.prototype.$msgbox = MessageBox;
// Vue.prototype.$alert = MessageBox.alert;
// Vue.prototype.$confirm = MessageBox.confirm;
// Vue.prototype.$prompt = MessageBox.prompt;
Vue.prototype.$notify = Notification;
// Vue.prototype.$message = Message;

Vue.component('forum-register', ForumRegister)
Vue.component('event-register', EventRegister)
Vue.component('payment-page', PaymentPage)

Vue.use(FormWizard)
Vue.use(VeeValidate, {
  mode: 'aggressive',
  events: 'change|blur',
  fieldsBagName: 'veeFields'
})

Vue.component(VueCountdown.name, VueCountdown)

// Currency Filter
Vue.filter('currency', function (money, symbol = null) {
  if (!symbol)
    return Accounting.formatMoney(money);
  return Accounting.formatMoney(money, {symbol, format: "%s %v"})
})

Vue.filter('capitalize', function (string) {
  return string.charAt(0).toUpperCase() + string.slice(1)
})

const MemberInitState = () => (
  {
    _id: uniqid(),
    searchFirstName: '',
    searchEmailOrMobileOrSyid: '',
    newSadhakProfile: {
      firstName: '',
      lastName: '',
      dateOfBirth: '',
      email: '',
      address: '',
      address2: '',
      city: null,
      state: null,
      country: null,
      gender: '',
      mobile: '',
      postalCode: '',
      otherState: null,
      otherCity: null,
      error: ''
    },
    sadhakProfile: {
      id: null,
      fullName: '',
      gender: '',
      obscureEmail: '',
      obscureMobile: '',
      city: '',
      state: '',
      country: '',
      isVerified: null,
      verifyLink: null, // profile verification link
      slug: null,
    },
    sadhakProfileId: null,
    isNew: false,
    seatingCategoryId: null,
    inquired: false,
    verifyResult: null
  }
)

const getMembersSeatingInfo = (state) => {
  const data = {
    "event_order_line_items_attributes": {}
  }
  state.members.forEach(member => {
    data["event_order_line_items_attributes"][member.sadhakProfileId] = {
      [state.forumId ? "syid" : "sadhak_profile_id"]: member.sadhakProfileId,
      "event_seating_category_association_id": member.seatingCategoryId
    }
  })
  return data
}

/****************************************************
 *** CONSTANTS
 ***************************************************/
const MAX_MEMBER_SIZE = 100

// http status code
const NOT_FOUND = 404
const UNPROCESSABLE_ENTITY = 422

window.store = new Vuex.Store({
  state: {
    forumId: null,
    eventId: null,
    seatingCategoryList: null,
    currencyCode: null,
    currentUserEmail: null,
    guestEmail: null,
    eventFree: false,
    preApprovalRequired: false,
    fullProfileNeeded: false,
    members: [
      MemberInitState()
    ],
    verifyMembersResult: null,
    renew: null,                                          // renew checkbox in Member Transfer Component
    processClubMembersResult: null,
    payMethod: null,
    stripePaymentForm: {
      name: '',
      cardNumber: '',
      cvv: '',
      expMon: '',
      expYear: '',
      mobile: '',
      email: '',
      token: null
    },
    billForm: {
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
    cashForm: {
      comment: '',
      isTermsAccepted: false
    },
    demandDraftForm: {
      fullName: '',
      mobile: '',
      email: '',
      ddNumber: '',
      ddDate: null,
      bankName: '',
      isTermsAccepted: false
    }
  },
  getters: {
    isDuplicated: (state) => (sadhakProfileId) => {
      return sadhakProfileId && state.members.findIndex((member) => member.sadhakProfileId === sadhakProfileId) > -1
    },
    memberCount: (state) => state.members.length,
    sadhakProfile: (state) => (id) => state.members[id].sadhakProfile,
    memberRegistered: (state, getters) => (id) => {
      if (state.members[id].sadhakProfileId) return true
      return false
    },
    memberCountToRegister: (state, getters) => {
      return state.members.filter((member, id) => !getters.memberRegistered(id)).length
    },
    currencySymbol: (state) => state.currencyCode,
    paymentSummary: (state) => {
      if (state.processClubMembersResult)
        return state.processClubMembersResult.summary
      return {
        "total_registration_fee": 0,
        "amount_before_taxes": 0,
        "service_tax": 0,
        "total_payable_amount": 0,
        "discount": 0,
        "tax_breakup": [
          {
            "tax_name": "IGST",
            "amount": 0
          }
        ]
      }
    },
    gateways: (state) => {
      if (state.processClubMembersResult)
        return state.processClubMembersResult.gateways
      return null
    },
    publishableKey: (state, getters) => {
      try {
        return getters.gateways['stripe'].publishable_key
      } catch (e) {
        return null
      }
    },
    priceSeating: (state, getters) => (seatingCategoryId) => {
      const seat = state.seatingCategoryList.find(seat => seat.id === seatingCategoryId)
      if (seat)
        return seat.price
      return null
    },
    receiveEmail: (state, getters) => {
      if (!getters.memberCount) return null
      return state.members[0].sadhakProfile.email
    },
    priceSum: (state, getters) => {
      let total = 0
      state.members.forEach(member => {
        if (member.seatingCategoryId)
          total += getters.priceSeating(member.seatingCategoryId)
      })
      return total
    },
    paymentDate: (state) => {
      if (state.processClubMembersResult)
        return state.processClubMembersResult.payment_date
      return null
    },
    paymentAmount: (state, getters) => (method) => {
      if (getters.gateways && getters.gateways[method]) {
        return getters.gateways[method].amount
      }
      return null
    },
    isFull: (state) => state.members.length === MAX_MEMBER_SIZE,
    maxMemberSize: (state) => MAX_MEMBER_SIZE,
    isIndiaEvent: (state) => {
      if (state.processClubMembersResult)
        return state.processClubMembersResult.is_india_event
      return null
    }
  },
  mutations: {
    addMember: (state) => {
      if (state.members.length < MAX_MEMBER_SIZE)
        state.members.push(MemberInitState())
    },
    removeMember: (state, id) => {
      if (state.members.length > 1)
        state.members.splice(id, 1)
    },
    updateStripePaymentForm: (state, data) => {
      state.stripePaymentForm = {...data}
    },
    updateNewSadhakProfile: (state, data) => {
      const {id, newSadhakProfile} = data
      Object.assign(state.members[id].newSadhakProfile, newSadhakProfile)
    },
    updateSadhakProfile: (state, data) => {
      const {id, sadhakProfile} = data
      Object.assign(state.members[id].sadhakProfile, sadhakProfile)
    },
    updateSearchFirstName: (state, data) => {
      const {id, val} = data
      state.members[id].searchFirstName = val
    },
    updateSearchEmailOrMobileOrSyid: (state, data) => {
      const {id, val} = data
      state.members[id].searchEmailOrMobileOrSyid = val
    },
    updateSadhakProfileId: (state, data) => {
      const {id, sadhakProfileId} = data
      state.members[id].sadhakProfileId = sadhakProfileId
    },
    resetMember: (state, id) => {
      Object.assign(state.members[id], MemberInitState())
    },
    setRegisterError: (state, data) => {
      const {id, error} = data
      state.members[id].newSadhakProfile.error = error
    },
    updateVerifyMembersResult: (state, data) => {
      state.verifyMembersResult = Object.assign({}, data)
      const {data: verifyDetails} = state.verifyMembersResult
      if(verifyDetails) {
        state.members.forEach(member => {
          member.verifyResult = verifyDetails.find(detail => detail.syid === "SY" + member.sadhakProfileId)
        })
      }
    },
    updateProcessClubMembersResult: (state, data) => {
      state.processClubMembersResult = Object.assign({}, data)
    },
    setForumId: (state, forumId) => {
      state.forumId = forumId
    },
    setEventId: (state, eventId) => {
      state.eventId = eventId
    },
    setSeatingCategoryList: (state, seatingCategoryList) => {
      state.seatingCategoryList = seatingCategoryList
    },
    updateSeatingCategoryId: (state, {id, seatingCategoryId}) => {
      state.members[id].seatingCategoryId = seatingCategoryId
    },
    setCurrency: (state, currencyCode) => {
      state.currencyCode = currencyCode
    },
    updateIsNew: (state, id) => {
      state.members[id].isNew = true
    },
    updateBillingForm: (state, billForm) => {
      Object.assign(state.billForm, billForm)
    },
    updatePayMethod: (state, payMethod) => {
      state.payMethod = payMethod
    },
    updateCashForm: (state, cashForm) => {
      Object.assign(state.cashForm, cashForm)
    },
    updateDemandDraftForm: (state, demandDraftForm) => {
      Object.assign(state.demandDraftForm, demandDraftForm)
    },
    updateMemberInquiried: (state, id) => {
      state.members[id].inquired = true
    },
    removeDummyMembers: (state) => {
      state.members = state.members.filter(member => member.inquired)
    },
    setCurrentUserEmail: (state, currentUserEmail) => {
      state.currentUserEmail = currentUserEmail
    },
    setGuestEmail: (state, guestEmail) => {
      state.guestEmail = guestEmail
    },
    updateSeatingCategoryIds: (state) => {
      state.members.forEach(member => {
        member.seatingCategoryId = state.seatingCategoryList[0].id
      })
    },
    updateRenew: (state, renew) => {
      state.renew = renew
    },
    setFree: (state, free) => {
      state.eventFree = free
    },
    setPreApprovalRequired: (state, preApprovalRequired) => {
      state.preApprovalRequired = preApprovalRequired
    },
    setFullProfileNeeded: (state, fullProfileNeeded) => {
      state.fullProfileNeeded = fullProfileNeeded
    },
    updateMemberVerifyState: (state, id) => {
      state.members[id].sadhakProfile.isVerified = true
    }
  },
  actions: {
    createBatchSadhakProfile({state, commit, getters}) {
      return new Promise(async (resolve, reject) => {
        const ary = state.members.filter((member, id) => !getters.memberRegistered(id))
          .map(member => ({
              "_id": member._id,
              "first_name": member.newSadhakProfile.firstName,
              "last_name": member.newSadhakProfile.lastName,
              "email": member.newSadhakProfile.email,
              "gender": member.newSadhakProfile.gender,
              "mobile": member.newSadhakProfile.mobile,
              "date_of_birth": member.newSadhakProfile.dateOfBirth,
              "address_attributes": {
                "first_line": member.newSadhakProfile.address,
                "second_line": member.newSadhakProfile.address2,
                "city_id": member.newSadhakProfile.city,
                "postal_code": member.newSadhakProfile.postalCode,
                "country_id": member.newSadhakProfile.country,
                "state_id": member.newSadhakProfile.state
              }
            })
          )

        console.log(ary)
        if (!ary.length) {
          resolve()
          return
        }

        try {
          const {data: result} = await Axios.post(`/batch_regist`, {
            "sadhak_profiles": ary
          })

          console.log(result)
          result.forEach(item => {
            const id = state.members.findIndex(member => member._id === item._id)
            if (!item.error) {
              const sadhakProfileId = item.id
              const sadhakProfile = {
                fullName: item.full_name,
                gender: item.gender,
                obscureEmail: item.obscure_email,
                obscureMobile: item.obscure_mobile,
                city: item.city,
                state: item.state,
                country: item.country,
                isVerified: item.is_verified,
                verifyLink: item.verify_link,
                slug: item.slug
              }
              commit('updateSadhakProfile', {id, sadhakProfile})
              commit('updateSadhakProfileId', {id, sadhakProfileId})
              commit('updateIsNew', id)
            } else {
              commit('setRegisterError', {id, error: item.error})
              console.log(`id: ${id}, error on registration: ${item.error}`)
              reject(item.error)
            }
          })

          resolve()
        } catch (err) {
          console.log(err)
          reject(err)
        }
      })
    },

    searchSyid: async ({state, commit, getters}, id) => {
      const params = {
        'first_name': state.members[id].searchFirstName,
        'mobile_email_syid': state.members[id].searchEmailOrMobileOrSyid
      }

      try {
        const {data: sadhak_profile} = await Axios.post(`/find_sadhak_profile`, params)

        if (sadhak_profile.id === undefined) {
          throw 'Need to Login'
        }

        // check duplication
        const find = state.members.filter(member => member.sadhakProfileId === sadhak_profile.id)
        if (find.length > 0)
          throw 'Duplicated!'

        // check member's eligibility of registration for the event
        if (!!state.eventId) {
          await Axios.post(`/events/${state.eventId}/verify_member.json`, {sadhak_profile})
        }

        //if(!!state.fullProfileNeeded && !sadhak_profile.is_verified) {
        // if(!sadhak_profile.is_verified) {
        //   const error = {
        //     needProfileVerified: true,
        //     message: 'this profile is not verified, it needs to be verified before being added to registration',
        //     verifyLink: sadhak_profile.verify_link,
        //     slug: sadhak_profile.slug
        //   }
        //   throw error
        // }

        commit('updateSadhakProfile', {
          id,
          sadhakProfile: {
            id: sadhak_profile.id,
            fullName: sadhak_profile.full_name,
            gender: sadhak_profile.gender,
            obscureEmail: sadhak_profile.obscure_email,
            obscureMobile: sadhak_profile.obscure_mobile,
            city: sadhak_profile.city,
            state: sadhak_profile.state,
            country: sadhak_profile.country,
            isVerified: sadhak_profile.is_verified,
            verifyLink: sadhak_profile.verify_link,
            slug: sadhak_profile.slug
          },
        })

        commit('updateSadhakProfileId', {id, sadhakProfileId: sadhak_profile.id})

        return true
      } catch (error) {
        throw error
      }
    },

    verifyMembers({state, commit}) {
      return new Promise((resolve, reject) => {
        const data = {
          "event_order": getMembersSeatingInfo(state)
        }
        console.log('------------verifyMembers----------------')
        console.log(data)
        Axios.post(`/forum/${state.forumId}/verify_members`, data).then((resp) => {
          commit('updateVerifyMembersResult', resp.data)
          resolve()
        }).catch((err) => {
          reject(err)
        })
      })
    },

    process_club_members({state, commit}) {
      return new Promise((resolve, reject) => {
        const data = new FormData
        data.append(`event_order[${state.verifyMembersResult.enc_key}]`, JSON.stringify(getMembersSeatingInfo(state)))
        if(state.renew !== null)
          data.append("event_order[is_renewal_process]", state.renew)

        Axios.post(`/forum/${state.forumId}/process_club_members`, data)
          .then((resp) => {
            commit('updateProcessClubMembersResult', resp.data)
            resolve(resp.data)
          })
          .catch(error => {
            if (error.response) {
              const {status} = error.response
              switch (status) {
                case UNPROCESSABLE_ENTITY:
                  reject(error.response.data.error)
                  break
                default:
                  reject('Internal Server Error')
              }
            } else {
              reject('Network Connection Error')
            }
          })
      })
    },

    createEventOrder({state, commit, getters}) {
      return new Promise((resolve, reject) => {
        const data = {
          "event_order": getMembersSeatingInfo(state),
          "guest_email": state.guestEmail
        }
        console.log('------------createEventOrder----------------')
        console.log(data)

        Axios.post(`/events/${state.eventId}/event_orders`, data)
          .then((resp) => {
            commit('updateProcessClubMembersResult', resp.data)
            resolve(resp.data)
          })
          .catch(error => {
            console.log(error)
            console.log(error.message)
            if (error.response) {
              const {status} = error.response
              switch (status) {
                case UNPROCESSABLE_ENTITY:
                  console.log(error.response)
                  reject(error.response.data.error)
                  break
                default:
                  reject('Internal Server Error')
              }
            } else {
              reject('Network Connection Error')
            }
          })
      })
    }
    ,
    pay(store) {
      const {state} = store
      const payment_details = state.processClubMembersResult
      const method = state.payMethod

      // build payment form data
      const form = new FormData
      form.append("utf8", "✓")
      form.append("method", method)

      // payment form data
      if (method === 'stripe') {
        form.append("payment_details[card_holder_name]", store.state.stripePaymentForm.name)
        form.append("payment_details[mobile]", store.state.stripePaymentForm.mobile)
        form.append("payment_details[billing_email]", store.state.stripePaymentForm.email)
        form.append("payment_details[stripeToken]", store.state.stripePaymentForm.token)
      } else if (method === 'ccavenue') {
        const {billForm} = store.state
        form.append("payment_details[billing_name]", billForm.name)
        form.append("payment_details[billing_address]", billForm.address)
        form.append("payment_details[billing_address_country]", billForm.country)
        form.append("payment_details[billing_address_state]", billForm.state)
        form.append("payment_details[billing_address_city]", billForm.city)
        form.append("payment_details[billing_address_postal_code]", billForm.postalCode)
        form.append("payment_details[billing_phone]", billForm.mobile)
        form.append("payment_details[billing_email]", billForm.email)
      } else if (method === 'hdfc') {
        const {billForm} = store.state
        form.append("payment_details[billing_name]", billForm.name)
        form.append("payment_details[billing_address]", billForm.address)
        form.append("payment_details[billing_address_country]", billForm.country)
        form.append("payment_details[billing_address_state]", billForm.state)
        form.append("payment_details[billing_address_city]", billForm.city)
        form.append("payment_details[billing_address_postal_code]", billForm.postalCode)
        form.append("payment_details[billing_phone]", billForm.mobile)
        form.append("payment_details[billing_email]", billForm.email)
        form.append("payment_details[is_terms_accepted]", billForm.isTermsAccepted)
      } else if (method === 'cash') {
        const {cashForm} = store.state
        form.append("payment_details[additional_details]", cashForm.comment)
        form.append("payment_details[is_terms_accepted]", cashForm.isTermsAccepted)
      } else if (method === 'sydd') {
        const {demandDraftForm: demandDraft} = store.state
        form.append("payment_details[full_name]", demandDraft.fullName)
        form.append("payment_details[mobile]", demandDraft.mobile)
        form.append("payment_details[email]", demandDraft.email)
        form.append("payment_details[dd_number]", demandDraft.ddNumber)
        form.append("payment_details[dd_date]", demandDraft.ddDate)
        form.append("payment_details[bank_name]", demandDraft.bankName)
        form.append("payment_details[is_terms_accepted]", demandDraft.isTermsAccepted)
      }

      // gateway specific data
      const {
        amount,
        config_id, payment_gateway_mode_association_id,
        enc_key: paymentDetailsKey,
        enc_val: encryptedPaymentDetails
      } = payment_details.gateways[state.payMethod]
      form.append("payment_details[amount]", amount)
      form.append("payment_details[config_id]", config_id)
      form.append(paymentDetailsKey, encryptedPaymentDetails)
      form.append("payment_details[payment_gateway_mode_association_id]", payment_gateway_mode_association_id)

      // common event_order data
      const {
        event_order_id, is_india_event, payment_date, upgrade, parent_event_order_id,
        event_order_line_item_ids: {enc_key: encKey1, enc_val: encVal1},
        sadhak_profile_details: {enc_key: encKey2, enc_val: encVal2}
      } = payment_details
      form.append("payment_details[payment_date]", payment_date)
      form.append("payment_details[event_order_id]", event_order_id)
      form.append("payment_details[upgrade]", upgrade)
      form.append("payment_details[parent_event_order_id]", parent_event_order_id)
      form.append(encKey1, encVal1)
      form.append(encKey2, encVal2)

      // call backend via api
      return Axios.post(`/event_orders/${event_order_id}/pay.json`, form)
      // return new Promise((resolve, reject) => {
      //   resolve(form)
      // })
    }
  }
})


document.addEventListener('turbolinks:load', () => {
  // This code will setup headers of X-CSRF-Token that it grabs from rails generated token in meta tag.
  Axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

  const element = document.querySelectorAll('[data-behavior="vue"]');
  if (element.length > 0) {
    console.log('creating new vue instance')
    const app = new Vue({
      el: '[data-behavior="vue"]',
      store: window.store
    })
  }
})
