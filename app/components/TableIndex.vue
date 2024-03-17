<script>
import { TABS } from './DrugDetail.vue';
export const formatContent = valueList => {
  let content = ''
  valueList.forEach(val => {
    switch (val.type) {
      case 'label':
        content += `${content !== '' ? '<br>' : ''}<span class="tableIndex_label">${val.value}</span>`
        break;
      case 'text':
        content += val.value
        break;
      case 'table':
        content += '<table class="tableIndex_table"><tr>'
        val.value.forEach(cell => {
          if (cell.pos.column === 1 && cell.pos.row !== 1) {
            content += `</tr><tr>`
          }
          content += `<td>${cell.value}</td>`
        })
        content += '</tr></table>'
        break;
      default:
        break;
    }
  })
  return content
}
</script>
<script setup>
const props = defineProps({
  tableContents: {
    type: Array,
    required: true,
  },
  activeTab: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    required: true,
  },
  drugId: {
    type: String,
    required: true,
  }
})
const { tableContents, activeTab, type, drugId } = toRefs(props)
const anotherTab = computed(() => activeTab.value === TABS.pi ? TABS.if : TABS.pi)

// 親子関係を構築したデータ構造に変換する関数
const buildTree = (items) => {
  const map = {};
  const result = [];

  // マップを使って親子関係を構築
  items.forEach(item => {
    if (!map[item.content_id]) {
      map[item.content_id] = { ...item, open: false, children: [], targetContent: null };
    }
    if (item.parent_content_id && !map[item.parent_content_id]) {
      map[item.parent_content_id] = { children: [] };
    }
    if (item.parent_content_id) {
      map[item.parent_content_id].children.push(map[item.content_id]);
    } else {
      result.push(map[item.content_id]);
    }
  });

  return result;
};
const hierarchizedTableContents = ref(buildTree(tableContents.value))

const config = useRuntimeConfig()

const getContent = async (sectionId) => {
  try {
    const data = await fetch(`${config.public.API_URL}/interview_form_${type.value}_section?${type.value}_id=${drugId.value}&section_id=${sectionId}`)
    const targetData = await data.json()
    const targetContent = targetData.value_list.length > 0 ? formatContent(targetData.value_list) : 'データがありません'
    return { targetContent, refData: targetData[`${anotherTab.value}_link_list`] }
  } catch (error) {
    console.error(error);
    return null;
  }
}

// コンテンツの内容を取得し、状態に保存
const updateContent = async (content) => {
  const data = await getContent(content.content_id);
  content.targetContent = data.targetContent
  content.refData = data.refData
}

// コンテンツの開閉状態を切り替える
const toggleContent = async (content, isOpen) => {
  content.open = isOpen ?? !content.open;
  if (content.open && !content.targetContent) {
    await updateContent(content);
  }
}

const route = useRoute()

const moveToTargetSection = () => {
  const sectionId = route.query.sectionId
  if (!sectionId) return
  openTargetSection(hierarchizedTableContents.value, sectionId)
  nextTick(() => {
    const targetEl = document.getElementById(sectionId);
    targetEl?.scrollIntoView({ behavior: 'smooth' }, true);
  })
}

const openTargetSection = (contents, sectionId) => {
  const content = findChildContentById(contents, sectionId)
  if (!content) return
  toggleContent(content, true)
  if (content.children.length > 0) {
    openTargetSection(content.children, sectionId)
  }
}

const findChildContentById = (contents, id) => {
  const idParts = id.split('_');
  for (let i = 0; i < contents.length; i++) {
    const parts = contents[i].content_id.split('_');
    if (parts.every((part, idx) => idParts[idx] === part)) {
      return contents[i];
    }
  }
  return null;
}

defineExpose({
  moveToTargetSection
})
</script>

<template>
  <ul>
    <li v-for="content in hierarchizedTableContents" :key="content.content_id" class="tableIndex_index"
      @click.stop="toggleContent(content)">
      {{ content.content_no }}　{{ content.content_label }}
      <ul v-if="content.children.length > 0 && content.open" class="tableIndex_childIndexWrapper" @click.stop>
        <li v-for="childContent in content.children" :key="childContent.content_id" :id="childContent.content_id"
          class="tableIndex_childIndex" :class="{ 'tableIndex_childIndex-open': childContent.open }"
          @click.stop="toggleContent(childContent)">
          {{ childContent.content_no }} {{ childContent.content_label }}
          <ul v-if="childContent.children.length > 0 && childContent.open" class="tableIndex_childIndexWrapper"
            @click.stop>
            <li v-for="grandChildContent in childContent.children" :key="grandChildContent.content_id"
              :id="grandChildContent.content_id" class="tableIndex_childIndex"
              :class="{ 'tableIndex_childIndex-open': grandChildContent.open }"
              @click.stop="toggleContent(grandChildContent)">
              {{ grandChildContent.content_no }} {{ grandChildContent.content_label }}
              <TableIndexContent v-if="grandChildContent.open" :drug-id="drugId" :child-content="grandChildContent"
                :another-tab="anotherTab" />
            </li>
          </ul>
          <TableIndexContent v-else-if="childContent.open" :drug-id="drugId" :child-content="childContent"
            :another-tab="anotherTab" />
        </li>
      </ul>
      <TableIndexContent v-else-if="content.open" :drug-id="drugId" :child-content="content"
        :another-tab="anotherTab" />
    </li>
  </ul>
</template>

<style lang="scss">
.tableIndex {
  &_index {
    font-size: 14px;
    padding: 10px;
    border-bottom: 1px solid #e9eef0;
    cursor: pointer;
    font-weight: bold;
  }

  &_childIndexWrapper {
    margin-top: 10px;
  }

  &_childIndex {
    font-weight: normal;
    font-size: 13px;
    padding: 8px 0 8px 14px;
    position: relative;

    &::before {
      content: '';
      width: 5px;
      height: 5px;
      border-left: 1px solid #333;
      border-top: 1px solid #333;
      transform: rotate(-135deg);
      display: block;
      margin-right: 10px;
      position: absolute;
      top: 10px;
      left: 2px;
      transition: transform .3s;
    }

    &-open {
      &::before {
        transform: rotate(45deg);
      }
    }
  }
}
</style>
