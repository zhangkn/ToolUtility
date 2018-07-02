//
//  HXTagsView.m
//  黄轩 https://github.com/huangxuan518
//
//  Created by 黄轩 on 16/1/13.
//  Copyright © 2015年 IT小子. All rights reserved.
//

#import "TagsView.h"
#import "TagCollectionViewCell.h"
#import "TagAttribute.h"

@interface HXTagsView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic,strong) NSMutableArray *selectedTags;
@property (nonatomic,strong) UICollectionView *collectionView;

@end

@implementation HXTagsView

static NSString * const reuseIdentifier = @"HXTagCollectionViewCellId";

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.userInteractionEnabled = YES;
    
    // 初始化样式
    _tagAttribute = [HXTagAttribute normal];
    _tagSelectedAttribute = [HXTagAttribute selected];
    
    _layout = [_tagAttribute tagCellCollectionViewFlowLayout];
    
    [self addSubview:self.collectionView];
    
    // 初始化默认数据
    self.isMultiSelect = NO;
    self.selectCountLimit = -1;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _tags.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    HXTagCollectionViewFlowLayout *layout = (HXTagCollectionViewFlowLayout *)collectionView.collectionViewLayout;
    CGSize maxSize = CGSizeMake(collectionView.frame.size.width - layout.sectionInset.left - layout.sectionInset.right, layout.itemSize.height);
    
    CGRect frame = [_tags[indexPath.item] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:_tagAttribute.titleSize]} context:nil];
    
    return CGSizeMake(frame.size.width + _tagAttribute.tagSpace, layout.itemSize.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HXTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    cell.backgroundColor = _tagAttribute.backgroundColor;
    cell.layer.cornerRadius = _tagAttribute.cornerRadius;
    cell.layer.borderColor = _tagAttribute.borderColor.CGColor;
    cell.layer.borderWidth = _tagAttribute.borderWidth;
    cell.titleLabel.textColor = _tagAttribute.textColor;
    cell.titleLabel.font = [UIFont systemFontOfSize:_tagAttribute.titleSize];
    
    NSString *title = self.tags[indexPath.item];
    if (_key.length > 0) {
        cell.titleLabel.attributedText = [self searchTitle:title key:_key keyColor:_tagAttribute.keyColor];
    } else {
        cell.titleLabel.text = title;
    }
        
    if ([self.selectedTags containsObject:self.tags[indexPath.item]]) {
        cell.layer.borderColor = _tagSelectedAttribute.borderColor.CGColor;
        cell.titleLabel.textColor = _tagSelectedAttribute.textColor;
        cell.backgroundColor = _tagSelectedAttribute.backgroundColor;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return;
    HXTagCollectionViewCell *cell = (HXTagCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if ([self.selectedTags containsObject:self.tags[indexPath.item]]) { // 如果有，则反选
        cell.layer.borderColor = _tagAttribute.borderColor.CGColor;
        cell.layer.borderWidth = _tagAttribute.borderWidth;
        cell.backgroundColor = _tagAttribute.backgroundColor;
        cell.titleLabel.textColor = _tagAttribute.textColor;
        
        [self.selectedTags removeObject:self.tags[indexPath.item]];
    } else {
        if (_isMultiSelect) {
            cell.layer.borderColor = _tagSelectedAttribute.borderColor.CGColor;
            cell.titleLabel.textColor = _tagSelectedAttribute.textColor;
            
            cell.backgroundColor = _tagSelectedAttribute.backgroundColor;
            
            [self.selectedTags addObject:self.tags[indexPath.item]];
        } else {
            [self.selectedTags removeAllObjects];
            [self.selectedTags addObject:self.tags[indexPath.item]];
            
            [self reloadData];
        }
    }
    
    if (_completion) {
        _completion(self.selectedTags,indexPath.item);
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 如果已经选中了，则可以反选
    if ([self.selectedTags containsObject:self.tags[indexPath.item]]) {
        return YES;
    }
    
    // 如果未选中，则查看限制
    if (_isMultiSelect && self.selectCountLimit > 0) {
        if (self.selectedTags.count >= self.selectCountLimit) {
            return NO;
        }
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selected = YES;
    
    return YES;
}

// 设置文字中关键字高亮
- (NSMutableAttributedString *)searchTitle:(NSString *)title key:(NSString *)key keyColor:(UIColor *)keyColor {
    
    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:title];
    NSString *copyStr = title;
    
    NSMutableString *xxstr = [NSMutableString new];
    for (int i = 0; i < key.length; i++) {
        [xxstr appendString:@"*"];
    }
    
    while ([copyStr rangeOfString:key options:NSCaseInsensitiveSearch].location != NSNotFound) {
        
        NSRange range = [copyStr rangeOfString:key options:NSCaseInsensitiveSearch];
        
        [titleStr addAttribute:NSForegroundColorAttributeName value:keyColor range:range];
        copyStr = [copyStr stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:xxstr];
    }
    return titleStr;
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _collectionView.frame = self.bounds;
}

#pragma mark - 懒加载

- (NSMutableArray *)selectedTags {
    if (!_selectedTags) {
        _selectedTags = [NSMutableArray array];
    }
    return _selectedTags;
}

- (void)setDefaultSelectedTags:(NSArray *)defaultSelectedTags {
    _defaultSelectedTags = defaultSelectedTags;
    [self.selectedTags removeAllObjects];
    // add to selected tags
    [self.selectedTags addObjectsFromArray:defaultSelectedTags];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.userInteractionEnabled = YES;
        [_collectionView registerClass:[HXTagCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    }
    
    _collectionView.collectionViewLayout = _layout;
    
    if (_layout.scrollDirection == UICollectionViewScrollDirectionVertical) {
        //垂直
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
    } else {
        _collectionView.showsHorizontalScrollIndicator = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    
    _collectionView.frame = self.bounds;
    
    return _collectionView;
}

+ (CGFloat)getHeightWithTags:(NSArray *)tags layout:(HXTagCollectionViewFlowLayout *)layout tagAttribute:(HXTagAttribute *)tagAttribute width:(CGFloat)width {
    CGFloat contentHeight;
    
    if (!layout) {
        layout = [tagAttribute tagCellCollectionViewFlowLayout];
    }
    
    if (tagAttribute.titleSize <= 0) {
        tagAttribute = [[HXTagAttribute alloc] init];
    }
    
    //cell的高度 = 顶部 + 高度
    contentHeight = layout.sectionInset.top + layout.itemSize.height;

    CGFloat originX = layout.sectionInset.left;
    CGFloat originY = layout.sectionInset.top;
    
    NSInteger itemCount = tags.count;
    
    for (NSInteger i = 0; i < itemCount; i++) {
        CGSize maxSize = CGSizeMake(width - layout.sectionInset.left - layout.sectionInset.right, layout.itemSize.height);
        
        CGRect frame = [tags[i] boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:tagAttribute.titleSize]} context:nil];
        
        CGSize itemSize = CGSizeMake(frame.size.width + tagAttribute.tagSpace, layout.itemSize.height);
        
        if (layout.scrollDirection == UICollectionViewScrollDirectionVertical) {
            //垂直滚动
            if ((originX + itemSize.width + layout.sectionInset.right/2) > width) {
                originX = layout.sectionInset.left;
                originY += itemSize.height + layout.minimumLineSpacing;
                
                contentHeight += itemSize.height + layout.minimumLineSpacing;
            }
        }
        
        originX += itemSize.width + layout.minimumInteritemSpacing;
    }
    
    contentHeight += layout.sectionInset.bottom;
    return contentHeight;
}

@end
