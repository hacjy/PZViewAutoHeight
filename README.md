# PZCellAutoHeight
基于自动布局的cell自动高度

# 使用方法超级简单
step 1:UITableViewDelegate

```object-c
- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [Cell heightByData:CellData];
}
```
step 2:Cell中有两种写法
方式一:实现`- (void)setData:(id _Nullable)data`方法，并在其中填充Cell数据
方法二:如果你已经有了自定义的Cell数据填充方法，那么，你可以在Cell初始化的时候设置`pzSetDataSel`为你自定义的Cell数据填充方法
