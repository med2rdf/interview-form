<script>
import { formatContent } from './TableIndex.vue';
</script>
<script setup>
const props = defineProps({
  childContent: {
    type: Object,
    required: true,
  },
  anotherTab: {
    type: String,
    required: true,
  },
  drugId: {
    type: String,
    required: true,
  }
})
const { childContent, anotherTab, drugId } = toRefs(props)

const config = useRuntimeConfig()

const toggleRefData = (ref) => {
  ref.isOpen = !ref.isOpen
  if (ref.isOpen && !ref[`${anotherTab.value}_section_body`]) {
    getRefData(ref)
  }
}

const getRefData = async (reference) => {
  const data = await fetch(`${config.public.API_URL}/interview_form_${anotherTab.value}_section?${anotherTab.value}_id=${reference[`${anotherTab.value}_id`]}&section_id=${reference[`${anotherTab.value}_section_id`]}`)
  const refData = await data.json()
  reference[`${anotherTab.value}_section_body`] = refData.value_list.length > 0 ? formatContent(refData.value_list) : 'データがありません'
  reference.isOpen = ref(true)
}

const route = useRoute()
const router = useRouter()
const emits = defineEmits()
const moveToRef = (ref) => {
  // すでに該当のクエリの場合は親のメソッドを直接呼び出す
  if (
    route.query.type === anotherTab.value &&
    route.query.drugId === drugId.value &&
    route.query.sectionId === ref[`${anotherTab.value}_section_id`]
  ) {
    emits('move-to-target-section', route.query.sectionId)
  } else {
    router.push({ query: { type: anotherTab.value, drugId: drugId.value, sectionId: ref[`${anotherTab.value}_section_id`] } })
  }
}
</script>

<template>
  <div v-if="childContent.isHistoryBackShown" class="tableIndex_back">
    <span @click.stop="$emit('back-to-prev')">参照元にもどる</span>
  </div>
  <LoadingIcon v-if="!childContent.targetContent" />
  <div class="tableIndex_body" v-html="childContent.targetContent" @click.stop></div>
  <div v-if="childContent.refData" @click.stop>
    <div v-for="ref in childContent.refData" class="tableIndex_ref" :class="`tableIndex_ref-${anotherTab}`">
      <div class="tableIndex_refTitle" :class="{ 'tableIndex_refTitle-open': ref.isOpen }" @click="toggleRefData(ref)">
        <span @click.stop="moveToRef(ref)">
          {{ ref[`${anotherTab}_section_no`] }} {{ ref[`${anotherTab}_section_name`] }}
        </span>
      </div>
      <LoadingIcon v-if="ref.isOpen && !ref[`${anotherTab}_section_body`]" />
      <div v-show="ref.isOpen" v-html="ref[`${anotherTab}_section_body`]" class="tableIndex_refBody"
        :class="{ 'tableIndex_refBody-open': ref.isOpen }"></div>
    </div>
  </div>
</template>

<style lang="scss">
.tableIndex {
  &_back {
    margin-left: 15px;
    display: inline-block;
    font-weight: normal;
    font-size: 13px;
    position: relative;

    span {
      color: $main_color;
      text-decoration: underline;
      z-index: 1;
      position: relative;
    }

    &::before {
      content: '';
      width: 8px;
      height: 8px;
      background-color: #e5f3f6;
      display: inline-block;
      position: absolute;
      top: 50%;
      transform: translateY(-50%) rotate(-45deg);
      left: -15px;
    }

    &::after {
      content: '';
      border-radius: 2px;
      padding: 6px 10px;
      width: calc(100% + 4px);
      height: calc(100% + 6px);
      background-color: #e5f3f6;
      position: absolute;
      top: 50%;
      left: calc(50% + 2px);
      transform: translate(-50%, -50%);
      z-index: 0;
    }
  }

  &_body {
    margin-top: 8px;
    font-weight: normal;
    line-height: 1.5;
  }

  &_label {
    margin-right: 4px;
    font-weight: bold;

    &:after {
      content: ':';
      margin-right: 2px;
    }
  }

  &_table {
    margin: 10px 0;

    th,
    td {
      border: 1px solid #000000;
      padding: 4px 8px;
    }
  }

  &_ref {
    border-radius: 5px;
    padding: 12px 18px;
    margin: 8px 0;
    font-weight: normal;

    .tableIndex_refTitle {
      text-decoration: underline;
      display: flex;
      align-items: center;

      &:before {
        content: '';
        width: 16px;
        height: 16px;
        margin-right: 8px;
        background-size: contain;
        display: block;
      }

      &::after {
        content: "";
        width: 5px;
        height: 5px;
        border-left: 1px solid #333;
        border-top: 1px solid #333;
        transform: rotate(-135deg);
        display: block;
        margin-right: 10px;
        transition: transform 0.3s;
        margin-left: auto;
      }

      &-open:after {
        transform: rotate(45deg);
      }
    }

    &-pi {
      background-color: $pi_pale_color;

      .tableIndex_refTitle:before {
        background-image: url('assets/images/icon-PI.png');
      }
    }

    &-if {
      background-color: $if_pale_color;

      .tableIndex_refTitle:before {
        background-image: url('assets/images/icon-IF.png');
      }
    }
  }

  &_refBody {
    font-size: 13px;
    line-height: 1.2;

    &-open {
      margin-top: 8px;
    }
  }
}
</style>
