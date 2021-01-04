<template>
  <div>
    <search-box :id="id" :isFound="memberRegistered"
                @triggered="search"
                @switchoff="resetForm"
                @switchon="search"
                @remove="removeItem"
    />
    <template v-if="memberRegistered !== null && inquiried">
      <!-- when profile is found and added to registration -->
      <sadhak-profile-detail v-if="memberRegistered" :id="id"/>
      <!-- when profile is found but not eligible for registration -->
      <div
          v-if="!memberRegistered && !formVisibility && errorMessage"
          class="alert-warning p-3 animated fadeIn"
          role="alert"
      >
        This member could not be registered because <strong>{{ errorMessage }}</strong>
      </div>
      <!-- when profile is not found -->
      <new-sadhak-profile v-if="!memberRegistered && formVisibility" :id="id" ref="newSadhakProfile"/>
    </template>
  </div>
</template>
<script>
  import Axios from "axios";
  import {mapState, mapGetters, mapMutations} from "vuex"
  import NewSadhakProfile from "./new_sadhak_profile"
  import SadhakProfileDetail from "./sadhak_profile_detail"
  import SearchBox from "./search_box"

  export default {
    props: {
      id: Number
    },
    components: {
      NewSadhakProfile,
      SadhakProfileDetail,
      SearchBox
    },
    data: function () {
      return {
        inquiried: false,
        prevCriteria: {
          firstName: '',
          emailMobileSyid: ''
        },
        formVisibility: false,
        errorMessage: '',
      }
    },
    computed: {
      memberRegistered: function () { return this.$store.getters.memberRegistered(this.id) }
    },
    methods: {
      removeItem: function () {
        this.$store.commit('removeMember', this.id)
      },
      resetForm: function () {
        this.prevCriteria.firstName = ''
        this.prevCriteria.emailMobileSyid = ''

        if (!!this.$refs.newSadhakProfile) {
          this.$nextTick().then(() => {
            this.$refs.newSadhakProfile.resetForm()
          })
        }

        this.$store.commit('resetMember', this.id)
      },
      search: function (searchCriteria) {
        const {firstName, emailMobileSyid} = searchCriteria

        if (firstName == this.prevCriteria.firstName &&
          emailMobileSyid == this.prevCriteria.emailMobileSyid)
          return;

        let loading = this.$loading({fullscreen: true, text: 'Searching Sadhak Profile...'})
        this.$store.dispatch('searchSyid', this.id).then(() => {
          loading.close()
          showNotification("alert-success", 'Successfully Added', "bottom", "center", "", "");
        }).catch((error) => {
          loading.close()

          if (error.response) {
            switch (error.response.status) {
              case 404:
                showNotification("alert-danger", 'No sadhak profiles found!', "bottom", "center", "", "");
                this.formVisibility = true
                this.errorMessage = ''
                break
              case 422:
                this.errorMessage = error.response.data.error
                this.formVisibility = false
                break
              default:
                showNotification("alert-danger", 'Unknown error!', "bottom", "center", "", "");
                this.formVisibility = false
                this.errorMessage = ''
                break
            }
          } else {
            this.formVisibility = false
            this.errorMessage = ''
            showNotification("alert-danger", error, "bottom", "center", "", "");
          }
        })

        Object.assign(this.prevCriteria, searchCriteria)
        this.inquiried = true
        this.updateMemberInquiried(this.id)
      },
      validate: function () {
        if (this.$refs.newSadhakProfile)
          return this.$refs.newSadhakProfile.validate()

        return new Promise((resolve, reject) => {
          if (!this.inquiried) {
            resolve(false)
          }
          resolve(true)
        })
      },
      ...mapMutations(['updateMemberInquiried'])
    }
  }
</script>
