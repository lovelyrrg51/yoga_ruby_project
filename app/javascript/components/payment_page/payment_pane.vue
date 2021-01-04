<template>
  <div :id="`pane-${name}`" class="card tab-pane fade" :class="{'show active':active}" role="tabpanel" :aria-labelledby="`tab-${name}`">
    <div class="card-header" role="tab" :id="`heading-${name}`">
      <a :class="{'collapsed': !active}" data-toggle="collapse" :href="`#collapse-${name}`" :aria-expanded="active" :aria-controls="`collapse-${name}`">
        <span class="stripe_icon"></span> {{title}}
      </a>
    </div>
    <div :id="`collapse-${name}`" :class="{'collapse': true, 'show': active}" role="tabpanel" data-parent="#content"
         :aria-labelledby="`heading-${name}`">
      <div class="card-body">
        <div class="row">
          <div class="col-sm-12 col-md-12 col-lg-7">
            <slot></slot>
          </div>
          <div class="col-sm-12 col-md-12 col-lg-5">
            <PaymentSummary :payMethod="name"/>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import PaymentSummary from './payment_summary'
  export default {
    props: {
      name: String,
      title: String,
      active: {
        type: Boolean,
        default: false
      }
    },
    components: {
      PaymentSummary
    },
    data: function () {
      return {}
    }
  }
</script>

<style>

</style>
