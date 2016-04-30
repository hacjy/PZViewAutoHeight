# PZCellAutoHeight
基于自动布局的View自动高度计算

# 使用方法超级简单
step 1:UITableViewDelegate

```object-c
- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [Cell heightByData:CellData];
}
```
step 2:View中有两种写法
方式一:实现`- (void)setData:(id _Nullable)data`方法，并在其中填充View数据
方法二:如果你已经有了自定义的View数据填充方法，那么，你可以在View初始化的时候设置`pzSetDataSel`为你自定义的View数据填充方法

step 3:在View初始化时，请指定`pzLastSubView`为当前View的最底部控件,和距离View底部的距离`pzBottomOffset`

以上三步设置完就可以使用了
原理:自动布局的View在数据填充之后，调用一下View的`layoutIfNeeded`就可以获取到各个控件的frame，以此来根据`pzLastSubView`和`pzBottomOffset`计算出View的高度


Q:为什么要做成View的扩展，而不是UITableviewCell的扩展      
A:由于项目中需要给UITableview设置headerView，而headerView也是使用了自动布局，也想一行代码搞定高度计算，因此,为了更为方便就做成了View的扩展


Q:网上已经有很多Cell自动高度计算的库了，为什么要重复造轮子       
A:1).我看了别人写的,大部分写的都很复杂,代码量少则三五百行,多则几千行,极为不方便阅读,所以我写了这个,只有200行左右,其中核心代码也就20行左右      
  2).很多都是通过indePath去缓存Cell高度,而我是通过数据+cell去缓存

# 致谢
感谢HYBMasonryAutoCellHeight的作者给了我灵感      
感谢所有使用本开源库的开发者，感谢你们的使用和反馈。

# 联系我
邮箱:goo.gle@foxmail.com
