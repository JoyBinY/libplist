 /* swig.i */
 %module(package="libplist") PList
 %feature("autodoc", "1");
 %{
 /* Includes the header in the wrapper code */
 #include <plist/plist.h>
typedef struct {
	plist_t node;
	char should_keep_plist;
} PListNode;

PListNode *allocate_wrapper() {
	PListNode* wrapper = (PListNode*) malloc(sizeof(PListNode));
	if (wrapper) {
		memset(wrapper, 0, sizeof(PListNode));
		return wrapper;
	}
	return NULL;
}
 %}

%include "stdint.i"

/* Parse the header file to generate wrappers */
typedef enum {
	PLIST_BOOLEAN,
	PLIST_UINT,
	PLIST_REAL,
	PLIST_STRING,
	PLIST_UNICODE,
	PLIST_ARRAY,
	PLIST_DICT,
	PLIST_DATE,
	PLIST_DATA,
	PLIST_KEY,
	PLIST_NONE
} plist_type;

typedef struct {
} PListNode;

%extend PListNode {             // Attach these functions to struct Vector
	PListNode(plist_type t) {
		PListNode* node = NULL;
		switch (t) {
			case PLIST_ARRAY :
				node = allocate_wrapper();
				if (node) {
					node->node = plist_new_array();
				}
				break;
			case PLIST_DICT :
				node = allocate_wrapper();
				if (node) {
					node->node = plist_new_dict();
				}
				break;
			default :
				node = NULL;
				break;
		}
		return node;
	}

	PListNode(char* xml) {
		PListNode* plist = allocate_wrapper();
		plist_from_xml(xml, strlen(xml), &plist->node);
		return plist;
	}

	PListNode(char* bin, uint64_t len) {
		PListNode* plist = allocate_wrapper();
		plist_from_bin(bin, len, &plist->node);
		return plist;
	}

	~PListNode() {
		if (!$self->should_keep_plist) {
			plist_free($self->node);
		}
		free($self);
	}

	void add_sub_node(PListNode* subnode) {
		if (subnode) {
			plist_add_sub_node($self->node, subnode->node);
		}
	}

	void add_sub_key(char* k) {
		plist_add_sub_key_el($self->node, k);
	}

	void add_sub_string(char* s) {
		plist_add_sub_string_el($self->node, s);
	}

	void add_sub_bool(char b) {
		plist_add_sub_bool_el($self->node, b);
	}

	void add_sub_uint(uint64_t i) {
		plist_add_sub_uint_el($self->node, i);
	}

	void add_sub_real(double d) {
		plist_add_sub_real_el($self->node, d);
	}

	void add_sub_data(char* v, uint64_t l) {
		plist_add_sub_data_el($self->node, v, l);
	}

	PListNode* get_first_child() {
		PListNode* plist = allocate_wrapper();
		if (plist) {
			plist->node = plist_get_first_child(&$self->node);
			plist->should_keep_plist = 1;
		}
		return plist;
	}

	PListNode* get_next_sibling() {
		PListNode* plist = allocate_wrapper();
		if (plist) {
			plist->node = plist_get_next_sibling(&$self->node);
			plist->should_keep_plist = 1;
		}
		return plist;
	}

	PListNode* get_prev_sibling() {
		PListNode* plist = allocate_wrapper();
		if (plist) {
			plist->node = plist_get_prev_sibling(&$self->node);
			plist->should_keep_plist = 1;
		}
		return plist;
	}

	char* as_key() {
		char* k = NULL;
		plist_get_key_val($self->node, &k);
		return k;
	}

	char* as_string() {
		char* s = NULL;
		plist_get_string_val($self->node, &s);
		return s;
	}

	char as_bool() {
		char b;
		plist_get_bool_val($self->node, &b);
		return b;
	}

	uint64_t as_uint() {
		uint64_t i = 0;
		plist_get_uint_val($self->node, &i);
		return i;
	}

	double as_real() {
		double d = 0;
		plist_get_real_val($self->node, &d);
		return d;
	}

	char* as_data() {
		char* v;
		uint64_t l;
		plist_get_data_val($self->node, &v, &l);
		return v;
	}

	plist_type get_type() {
		return plist_get_node_type($self->node);
	}

	PListNode* find_node_by_key(char *s) {
		PListNode* plist = allocate_wrapper();
		if (plist) {
			plist->node = plist_find_node_by_key($self->node, s);
			plist->should_keep_plist = 1;
		}
		return plist;
	}

	PListNode* find_node_by_string(char* s) {
		PListNode* plist = allocate_wrapper();
		if (plist) {
			plist->node = plist_find_node_by_string($self->node, s);
			plist->should_keep_plist = 1;
		}
		return plist;
	}

	char* to_xml () {
		char* s = NULL;
		uint32_t l;
		plist_to_xml($self->node, &s, &l);
		return s;
	}

	char* to_bin () {
		char* s = NULL;
		uint32_t l;
		plist_to_bin($self->node, &s, &l);
		return s;
	}

	void from_xml (char* xml) {
		plist_from_xml(xml, strlen(xml), &$self->node);
	}

	void from_bin (char* data, uint64_t len) {
		plist_from_bin(data, len, &$self->node);
	}
};

