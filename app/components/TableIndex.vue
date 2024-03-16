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
  drugId: {
    type: String,
    required: true,
  }
})
const { tableContents, activeTab, drugId } = toRefs(props)

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
    const data = await fetch(`${config.public.API_URL}/interview_form_${activeTab.value}_section?${activeTab.value}_id=${drugId.value}&section_id=${sectionId}`)
    const targetData = await data.json()
    if (targetData.value_list.length < 1) return 'データがありません'
    let targetContent = ''
    targetData.value_list.forEach(val => {
      switch (val.type) {
        case 'label':
          targetContent += `<span class="tableIndex_label">${val.value}</span>`
          break;
        case 'text':
          targetContent += val.value
          break;
        case 'table':
          targetContent += '<table class="tableIndex_table"><tr>'
          val.value.forEach(cell => {
            if (cell.pos.column === 1 && cell.pos.row !== 1) {
              targetContent += `</tr><tr>`
            }
            targetContent += `<td>${cell.value}</td>`
          })
          targetContent += '</tr></table>'
          break;
        default:
          break;
      }
    })
    return targetContent
  } catch (error) {
    console.error(error);
    return null;
  }
}

// コンテンツの内容を取得し、状態に保存
const updateContent = async (content) => {
  content.targetContent = await getContent(content.content_id);
}

// コンテンツの開閉状態を切り替える
const toggleContent = async (content) => {
  content.open = !content.open;
  if (content.open && !content.targetContent) {
    await updateContent(content);
  }
}

</script>


<template>
  <ul>
    <li v-for="content in hierarchizedTableContents" :key="content.content_id" class="tableIndex_index"
      @click.stop="toggleContent(content)">
      {{ content.content_no }}　{{ content.content_label }}
      <ul v-if="content.children.length > 0 && content.open" class="tableIndex_childIndexWrapper">
        <li v-for="childContent in content.children" :key="childContent.content_id" class="tableIndex_childIndex"
          :class="{ 'tableIndex_childIndex-open': childContent.open }" @click.stop="toggleContent(childContent)">
          {{ childContent.content_no }} {{ childContent.content_label }}
          <ul v-if="childContent.children.length > 0 && childContent.open" class="tableIndex_childIndexWrapper">
            <li v-for="grandChildContent in childContent.children" :key="grandChildContent.content_id"
              class="tableIndex_childIndex" :class="{ 'tableIndex_childIndex-open': grandChildContent.open }"
              @click.stop="toggleContent(grandChildContent)">
              {{ grandChildContent.content_no }} {{ grandChildContent.content_label }}
              <div v-if="grandChildContent.open" class="tableIndex_body" v-html="grandChildContent.targetContent"></div>
            </li>
          </ul>
          <div v-else-if="childContent.open" class="tableIndex_body" v-html="childContent.targetContent"></div>
        </li>
      </ul>
      <div v-else-if="content.open" class="tableIndex_body" v-html="content.targetContent"></div>
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

  &_body {
    margin-top: 8px;
    font-weight: normal;
    line-height: 1.5;
  }

  &_label {
    background-color: #2e4d66;
    color: #ffffff;
    padding: 3px 6px;
    border-radius: 4px;
    font-size: 11px;
    margin-right: 4px;
  }

  &_table {
    margin: 10px 0;

    th,
    td {
      border: 1px solid #000000;
      padding: 4px 8px;
    }
  }
}
</style>
