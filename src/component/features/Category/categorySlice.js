import { createSlice, createAsyncThunk, createAction } from "@reduxjs/toolkit";
import categoryService from "./categoryService";

// Khởi tạo trạng thái ban đầu
const initialState = {
  categories: [], // Danh sách loại sản phẩm
  category: null, // Chi tiết sản phẩm
  isLoading: false, // Trạng thái đang tải
  isError: false, // Có lỗi xảy ra
  isSuccess: false, // Hành động thành công
  message: "", // Thông báo lỗi hoặc thành công
};

// Thunk để lấy danh sách sản phẩm
export const getCategories = createAsyncThunk(
  "category/list-category",
  async (_,thunkAPI) => {
    try {
      const data = await categoryService.getCategories();
      console.log(data);
      return data;
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data || error.message);
    }
  }
);

// Thunk để thêm sản phẩm mới
export const createCategory = createAsyncThunk(
  "category/add-category",
  async (categoryData, thunkAPI) => {
    try {
      return await categoryService.createCategory(categoryData);
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data || error.message);
    }
  }
);

// Thunk để lấy thông tin chi tiết sản phẩm
export const getACategory = createAsyncThunk(
  "category/detail",
  async (id, thunkAPI) => {
    try {
      return await categoryService.getCategory(id);
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data || error.message);
    }
  }
);

// Thunk để xóa sản phẩm
export const deleteACategory = createAsyncThunk(
  "category/delete",
  async (id, thunkAPI) => {
    try {
      return await categoryService.deleteCategory(id);
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data || error.message);
    }
  }
);

// Thunk để cập nhật sản phẩm
export const updateACategory = createAsyncThunk(
  "category/update",
  async (productData, thunkAPI) => {
    try {
      return await categoryService.updateCategory(productData);
    } catch (error) {
      return thunkAPI.rejectWithValue(error.response?.data || error.message);
    }
  }
);

// Action để reset trạng thái
export const resetState = createAction("RevertAll");

export const categorySlice = createSlice({
  name: "category",
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      // Xử lý getProducts
      .addCase(getCategories.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(getCategories.fulfilled, (state, action) => {
        // console.log(action.payload);
        state.isLoading = false;
        state.isError = false;
        state.isSuccess = true;
        state.categories = action.payload.data;
      })
      .addCase(getCategories.rejected, (state, action) => {
        state.isLoading = false;
        state.isError = true;
        state.isSuccess = false;
        state.message = action.payload;
      })

      // Xử lý createProduct
      .addCase(createCategory.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(createCategory.fulfilled, (state, action) => {
        state.isLoading = false;
        state.isError = false;
        state.isSuccess = true;
        state.categories.push(action.payload);
      })
      .addCase(createCategory.rejected, (state, action) => {
        state.isLoading = false;
        state.isError = true;
        state.isSuccess = false;
        state.message = action.payload;
      })

      // Xử lý getAProduct
      .addCase(getACategory.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(getACategory.fulfilled, (state, action) => {
        state.isLoading = false;
        state.isError = false;
        state.isSuccess = true;
        state.category = action.payload;
      })
      .addCase(getACategory.rejected, (state, action) => {
        state.isLoading = false;
        state.isError = true;
        state.isSuccess = false;
        state.message = action.payload;
      })

      // Xử lý deleteAProduct
      .addCase(deleteACategory.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(deleteACategory.fulfilled, (state, action) => {
        state.isLoading = false;
        state.isError = false;
        state.isSuccess = true;
        state.categories = state.categories.filter(
          (category) => category.id !== action.payload.id
        );
      })
      .addCase(deleteACategory.rejected, (state, action) => {
        state.isLoading = false;
        state.isError = true;
        state.isSuccess = false;
        state.message = action.payload;
      })

      // Xử lý updateAProduct
      .addCase(updateACategory.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(updateACategory.fulfilled, (state, action) => {
        state.isLoading = false;
        state.isError = false;
        state.isSuccess = true;
        state.categories = state.categories.map((category) =>
          category.id === action.payload.id ? action.payload : category
        );
      })
      .addCase(updateACategory.rejected, (state, action) => {
        state.isLoading = false;
        state.isError = true;
        state.isSuccess = false;
        state.message = action.payload;
      })

      // Xử lý resetState
      .addCase(resetState, () => initialState);
  },
});

export default categorySlice.reducer;
